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
module "gcp_subnets" {
  source  = "terraform-google-modules/network/google//modules/subnets"
  version = "3.3.0"

  project_id   = var.gcp_project
  network_name = module.gcp_network.network_name
  subnets = [
    {
      subnet_name   = "${var.gcp_resource_prefix}-subnet"
      subnet_ip     = "10.0.0.0/16"
      subnet_region = var.gcp_region
    }
  ]
}
module "gcp_firewall-rules" {
  source       = "terraform-google-modules/network/google//modules/firewall-rules"
  version      = "3.3.0"
  project_id   = var.gcp_project
  network_name = module.gcp_network.network_name
  rules = [
    {
      name                    = "${var.gcp_resource_prefix}-ingress"
      description             = "Ingress for ${var.gcp_resource_prefix}-vpc"
      direction               = "INGRESS"
      priority                = 1000
      ranges                  = ["0.0.0.0/0"]
      source_tags             = null
      source_service_accounts = null
      target_tags             = []
      target_service_accounts = null
      allow = [
        {
          protocol = "tcp"
          ports    = ["30000-32767"]
        },
        {
          protocol = "udp"
          ports    = ["30000-32767"]
        }
      ]
      deny       = []
      log_config = null
    },
    {
      name                    = "${var.gcp_resource_prefix}-egress"
      description             = "Egress rules for ${var.gcp_resource_prefix}-vpc"
      direction               = "EGRESS"
      priority                = 1000
      ranges                  = ["0.0.0.0/0"]
      source_tags             = null
      source_service_accounts = null
      target_tags             = []
      target_service_accounts = null
      allow = [
        {
          protocol = "all"
          ports    = []
        }
      ]
      deny       = []
      log_config = null
    },
    {
      name                    = "${var.gcp_resource_prefix}-private-ingress"
      description             = "Private Ingress rules for ${var.gcp_resource_prefix}-vpc"
      direction               = "INGRESS"
      priority                = 1000
      ranges                  = ["10.0.0.0/16"]
      source_tags             = null
      source_service_accounts = null
      target_tags             = []
      target_service_accounts = null
      allow = [
        {
          protocol = "all"
          ports    = []
        }
      ]
      deny       = []
      log_config = null
    },
  ]
  depends_on = [module.gcp_subnets]
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
  subnetwork         = module.gcp_subnets.subnets["${var.gcp_region}/${var.gcp_resource_prefix}-subnet"].self_link
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
  source_image_family  = "rhel-7"
  disk_size_gb         = 100
  disk_type            = "pd-ssd"
  disk_labels = {
    ibm-satellite = var.gcp_resource_prefix
  }
  access_config = [{
    nat_ip       = null
    network_tier = "PREMIUM"
  }]
  auto_delete     = true
  service_account = { email = "", scopes = [] }
  depends_on      = [module.satellite-location, module.gcp_firewall-rules]
}
module "gcp_hosts" {
  source             = "terraform-google-modules/vm/google//modules/compute_instance"
  region             = var.gcp_region
  network            = module.gcp_network.network_name
  subnetwork_project = var.gcp_project
  subnetwork         = module.gcp_subnets.subnets["${var.gcp_region}/${var.gcp_resource_prefix}-subnet"].self_link
  num_instances      = var.satellite_host_count + var.addl_host_count
  hostname           = "${var.gcp_resource_prefix}-host"
  instance_template  = module.gcp_host-template.self_link
  access_config = [{
    nat_ip       = null
    network_tier = "PREMIUM"
  }]
}
