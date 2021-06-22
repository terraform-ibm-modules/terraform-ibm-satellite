##########################################################
# GCP network, subnetwork and its firewall rules
##########################################################
module "gcp_network" {
  source          = "terraform-google-modules/network/google//modules/vpc"
  version         = "~> 3.3.0"
  project_id      = var.gcp_project
  network_name    = "${var.gcp_resource_prefix}-vpc"
  shared_vpc_host = false
}
module "gcp_firewall-rules" {
  source       = "terraform-google-modules/network/google//modules/firewall-rules"
  version      = "3.3.0"
  project_id   = var.gcp_project
  network_name = module.gcp_network.network_name
  rules = [
    {
      name                    = "allow-ssh-ingress"
      description             = "firewall rules for ${var.gcp_resource_prefix}-vpc"
      direction               = "INGRESS"
      priority                = 1000
      ranges                  = ["0.0.0.0/0"]
      source_tags             = null
      source_service_accounts = null
      target_tags             = ["ibm-satellite"]
      target_service_accounts = null
      allow = [
        {
          protocol = "tcp"
          ports    = ["22", "80", "443", "30000-32767"]
        },
        {
          protocol = "udp"
          ports    = ["30000-32767"]
        }
      ]
      deny       = []
      log_config = null
    }
  ]
}
module "gcp_subnets" {
  source  = "terraform-google-modules/network/google//modules/subnets"
  version = "3.3.0"

  project_id   = var.gcp_project
  network_name = module.gcp_network.network_name
  subnets = [
    {
      subnet_name   = "${var.gcp_resource_prefix}-${local.subnets[0]}"
      subnet_ip     = local.subnet_ips[0]
      subnet_region = var.gcp_region
    },
    {
      subnet_name   = "${var.gcp_resource_prefix}-${local.subnets[1]}"
      subnet_ip     = local.subnet_ips[1]
      subnet_region = var.gcp_region
    },
    {
      subnet_name   = "${var.gcp_resource_prefix}-${local.subnets[2]}"
      subnet_ip     = local.subnet_ips[2]
      subnet_region = var.gcp_region
    }
  ]
}
locals {
  subnets    = ["subnet1", "subnet2", "subnet3"]
  subnet_ips = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  subnet_ids = [for subnet in local.subnets : module.gcp_subnets.subnets["${var.gcp_region}/${var.gcp_resource_prefix}-${subnet}"].self_link]
}
##########################################################
# GCP Compute Template and Instances
##########################################################
resource "tls_private_key" "rsa_key" {
  count     = (var.ssh_public_key == null ? 1 : 0)
  algorithm = "RSA"
  rsa_bits  = 4096
}
module "gcp_host-template" {
  source     = "terraform-google-modules/vm/google//modules/instance_template"
  version    = "6.5.0"
  project_id = var.gcp_project
  # network     = module.gcp_network.network_name
  subnetwork         = local.subnet_ids[0]
  subnetwork_project = var.gcp_project
  name_prefix        = "${var.gcp_resource_prefix}-template"
  tags               = ["ibm-satellite", var.gcp_resource_prefix]
  labels = {
    ibm-satellite = var.gcp_resource_prefix
  }
  metadata = {
    ssh-keys       = var.ssh_public_key != null ? "${var.gcp_ssh_user}:${var.ssh_public_key}" : tls_private_key.rsa_key.0.public_key_openssh
    startup-script = module.satellite-location.host_script
  }
  # startup_script=module.satellite-location.host_script
  machine_type         = var.instance_type
  can_ip_forward       = false
  source_image_project = "rhel-cloud"
  source_image         = "rhel-7-v20201112"
  source_image_family  = "rhel-7"
  disk_size_gb         = 100
  disk_type            = "pd-standard"
  disk_labels = {
    ibm-satellite = var.gcp_resource_prefix
  }
  auto_delete     = true
  service_account = { email = "", scopes = [] }
  depends_on      = [module.satellite-location]
}
data "google_compute_zones" "available" {
  project = var.gcp_project
  region  = var.gcp_region
}
resource "google_compute_instance_from_template" "gcp_hosts" {
  count   = var.satellite_host_count + var.addl_host_count
  name    = "${var.gcp_resource_prefix}-host-${count.index}"
  project = var.gcp_project
  zone    = data.google_compute_zones.available.names[count.index % length(data.google_compute_zones.available.names)]
  network_interface {
    network            = module.gcp_network.network_name
    subnetwork         = element(local.subnet_ids, count.index)
    subnetwork_project = var.gcp_project
  }
  source_instance_template = module.gcp_host-template.self_link
}
