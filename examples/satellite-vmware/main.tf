# Configure the VMware vCloud Director Provider
provider "vcd" {
  user     = var.vcd_user
  password = var.vcd_password
  org      = var.vcd_org
  url      = var.vcd_url
  vdc      = var.vdc_name
}

locals {
  host_name_cp      = "${var.host_name}-cp"
  host_name_worker  = "${var.host_name}-worker"
  host_name_storage = "${var.host_name}-stg"

  # This is going to be a bit finicky, and jq would be better, but this is what we have for now
  # The insertionPoint variables indicate where we're going to make some changes to the ignition script.
  # We'll use replace() later when spinning up the VMs, filling in the hostname and (optionally) the SSH key provided.
  hostnameInsertionPoint = "\"files\": ["
  hostnameIgnition       = "\"files\": [{\"path\": \"/etc/hostname\", \"mode\": 420, \"contents\": {\"source\": \"data:text/plain;charset=utf-8;base64,%s\"}},"
  sshInsertionPoint      = "\"sshAuthorizedKeys\": [ \"\" ]"
  sshText                = format("\"sshAuthorizedKeys\": [ \"%s\" ]", var.ssh_public_key)
}

module "satellite-location" {
  source            = "terraform-ibm-modules/satellite/ibm//modules/location"
  is_location_exist = var.is_location_exist
  coreos_enabled    = true
  coreos_host       = true
  location          = var.location
  managed_from      = var.managed_from
  location_zones    = var.location_zones
  host_labels       = var.host_labels
  resource_group    = var.resource_group
}

# Used to obtain information from the already deployed Edge Gateway and network
module "ibm_vmware_solutions_shared_instance" {
  source                = "./modules/ibm-vmware-solutions-shared-instance/"
  count                 = var.vdc_edge_gateway_name != null ? 1 : 0
  vdc_edge_gateway_name = var.vdc_edge_gateway_name
  network_name          = var.dhcp_network_name
}

# Create the firewall rule to access the Internet
resource "vcd_nsxv_firewall_rule" "rule_internet" {
  count        = var.vdc_edge_gateway_name != null ? 1 : 0
  edge_gateway = module.ibm_vmware_solutions_shared_instance[0].edge_gateway_name
  name         = "${var.dhcp_network_name}-Internet"

  action = "accept"

  source {
    org_networks = [var.dhcp_network_name]
  }

  destination {
    ip_addresses = []
  }

  service {
    protocol = "any"
  }
}

# Create SNAT rule to access the Internet
resource "vcd_nsxv_snat" "rule_internet" {
  count        = var.vdc_edge_gateway_name != null ? 1 : 0
  edge_gateway = module.ibm_vmware_solutions_shared_instance[0].edge_gateway_name
  network_type = "ext"
  network_name = module.ibm_vmware_solutions_shared_instance[0].external_network_name_2

  original_address   = "${module.ibm_vmware_solutions_shared_instance[0].network_gateway}/24"
  translated_address = module.ibm_vmware_solutions_shared_instance[0].default_external_network_ip
}

# Create the firewall rule to allow SSH from the Internet
resource "vcd_nsxv_firewall_rule" "rule_internet_ssh" {
  count = tobool(var.allow_ssh) == true && var.vdc_edge_gateway_name != null ? 1 : 0

  edge_gateway = module.ibm_vmware_solutions_shared_instance[0].edge_gateway_name
  name         = "${var.dhcp_network_name}-Internet-SSH"

  action = "accept"

  source {
    ip_addresses = []
  }

  destination {
    ip_addresses = [module.ibm_vmware_solutions_shared_instance[0].default_external_network_ip]
  }

  service {
    protocol = "tcp"
    port     = 22
  }
}

# Create the firewall to access IBM Cloud services over the IBM Cloud private network
resource "vcd_nsxv_firewall_rule" "rule_ibm_private" {
  count        = var.vdc_edge_gateway_name != null ? 1 : 0
  edge_gateway = module.ibm_vmware_solutions_shared_instance[0].edge_gateway_name
  name         = "${var.dhcp_network_name}-IBM-Private"

  logging_enabled = "false"
  action          = "accept"

  source {
    org_networks = [var.dhcp_network_name]
  }

  destination {
    gateway_interfaces = [module.ibm_vmware_solutions_shared_instance[0].external_network_name_1]
  }

  service {
    protocol = "any"
  }
}

# Create SNAT rule to access the IBM Cloud services over a private network
resource "vcd_nsxv_snat" "rule_ibm_private" {
  count        = var.vdc_edge_gateway_name != null ? 1 : 0
  edge_gateway = module.ibm_vmware_solutions_shared_instance[0].edge_gateway_name
  network_type = "ext"
  network_name = module.ibm_vmware_solutions_shared_instance[0].external_network_name_1

  original_address   = "${module.ibm_vmware_solutions_shared_instance[0].network_gateway}/24"
  translated_address = module.ibm_vmware_solutions_shared_instance[0].external_network_ips_2
}

# Create vcd App
resource "vcd_vapp" "vmware_satellite_vapp" {
  name = var.vapp_name
}

# Connect org Network to vcpApp
resource "vcd_vapp_org_network" "satellite_network" {
  vapp_name              = vcd_vapp.vmware_satellite_vapp.name
  org_network_name       = var.dhcp_network_name
  reboot_vapp_on_removal = true
}

# Create VMs
# Control plane: 8x32, 100GB primary disk
# Worker nodes:  4x16, 25GB primary, 100GB secondary
# Storage nodes: 16x64, 25 GB primary, 100 GB secondary, 500 GB tertiary (configurable via vars)

resource "vcd_vapp_vm" "control_plane_vms" {
  count            = var.num_control_plane_hosts
  vapp_name        = vcd_vapp.vmware_satellite_vapp.name
  name             = "${local.host_name_cp}-${count.index}"
  computer_name    = "${local.host_name_cp}-${count.index}"
  vapp_template_id = var.rhcos_template_id
  cpus             = 8
  memory           = 32768
  override_template_disk {
    bus_type    = "paravirtual"
    size_in_mb  = "102400"
    bus_number  = 0
    unit_number = 0
    iops        = 0
  }
  network {
    type               = "org"
    name               = vcd_vapp_org_network.satellite_network.org_network_name
    ip_allocation_mode = "DHCP"
    is_primary         = true
    connected          = true
  }
  guest_properties = {
    # write the hostname and (optionally) SSH key into ignition
    "guestinfo.ignition.config.data"          = base64encode(replace(replace(module.satellite-location.host_script, local.hostnameInsertionPoint, format(local.hostnameIgnition, base64encode("${local.host_name_cp}-${count.index}"))), local.sshInsertionPoint, local.sshText))
    "guestinfo.ignition.config.data.encoding" = "base64"
  }
}
resource "vcd_vapp_vm" "worker_vms" {
  count            = var.num_worker_hosts
  vapp_name        = vcd_vapp.vmware_satellite_vapp.name
  name             = "${local.host_name_worker}-${count.index}"
  computer_name    = "${local.host_name_worker}-${count.index}"
  vapp_template_id = var.rhcos_template_id
  cpus             = 4
  memory           = 16384
  override_template_disk {
    bus_type    = "paravirtual"
    size_in_mb  = "25600"
    bus_number  = 0
    unit_number = 0
    iops        = 0
  }
  network {
    type               = "org"
    name               = vcd_vapp_org_network.satellite_network.org_network_name
    ip_allocation_mode = "DHCP"
    is_primary         = true
    connected          = true
  }
  guest_properties = {
    # write the hostname and (optionally) SSH key into ignition
    "guestinfo.ignition.config.data"          = base64encode(replace(replace(module.satellite-location.host_script, local.hostnameInsertionPoint, format(local.hostnameIgnition, base64encode("${local.host_name_worker}-${count.index}"))), local.sshInsertionPoint, local.sshText))
    "guestinfo.ignition.config.data.encoding" = "base64"
  }
}
resource "vcd_vm_internal_disk" "worker_disks" {
  count           = var.num_worker_hosts
  vapp_name       = vcd_vapp.vmware_satellite_vapp.name
  vm_name         = "${local.host_name_worker}-${count.index}"
  bus_type        = "paravirtual"
  size_in_mb      = "102400"
  bus_number      = 0
  unit_number     = 1
  allow_vm_reboot = true
  depends_on      = [vcd_vapp_vm.worker_vms]
}

resource "vcd_vapp_vm" "storage_vms" {
  count            = var.num_storage_hosts
  vapp_name        = vcd_vapp.vmware_satellite_vapp.name
  name             = "${local.host_name_storage}-${count.index}"
  computer_name    = "${local.host_name_storage}-${count.index}"
  vapp_template_id = var.rhcos_template_id
  cpus             = var.storage_vm_cpu
  memory           = var.storage_vm_memory
  override_template_disk {
    bus_type    = "paravirtual"
    size_in_mb  = var.storage_vm_disk0
    bus_number  = 0
    unit_number = 0
    iops        = 0
  }
  network {
    type               = "org"
    name               = vcd_vapp_org_network.satellite_network.org_network_name
    ip_allocation_mode = "DHCP"
    is_primary         = true
    connected          = true
  }
  guest_properties = {
    # write the hostname and (optionally) SSH key into ignition
    "guestinfo.ignition.config.data"          = base64encode(replace(replace(module.satellite-location.host_script, local.hostnameInsertionPoint, format(local.hostnameIgnition, base64encode("${local.host_name_storage}-${count.index}"))), local.sshInsertionPoint, local.sshText))
    "guestinfo.ignition.config.data.encoding" = "base64"
  }
}

resource "vcd_vm_internal_disk" "storage_disks" {
  count           = var.num_storage_hosts
  vapp_name       = vcd_vapp.vmware_satellite_vapp.name
  vm_name         = "${local.host_name_storage}-${count.index}"
  bus_type        = "paravirtual"
  size_in_mb      = var.storage_vm_disk1
  bus_number      = 0
  unit_number     = 1
  allow_vm_reboot = true
  depends_on      = [vcd_vapp_vm.storage_vms]
}

resource "vcd_vm_internal_disk" "storage_disks_2" {
  count           = var.num_storage_hosts
  vapp_name       = vcd_vapp.vmware_satellite_vapp.name
  vm_name         = "${local.host_name_storage}-${count.index}"
  bus_type        = "paravirtual"
  size_in_mb      = var.storage_vm_disk2
  bus_number      = 0
  unit_number     = 2
  allow_vm_reboot = true
  depends_on      = [vcd_vapp_vm.storage_vms]
}

# Assign control plane hosts to control plane
module "satellite-host" {
  source         = "terraform-ibm-modules/satellite/ibm//modules/host"
  host_count     = var.num_control_plane_hosts
  location       = module.satellite-location.location_id
  host_vms       = [for v in vcd_vapp_vm.control_plane_vms : v.name]
  location_zones = var.location_zones
  host_labels    = var.host_labels
}
