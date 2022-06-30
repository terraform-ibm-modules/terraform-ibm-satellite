#####################################################
# IBM Cloud Satellite -  IBM Example
# Copyright 2021 IBM
#####################################################

data "ibm_resource_group" "resource_group" {
  name = var.resource_group
}

data "ibm_is_image" "rhel7" {
  name = "ibm-redhat-7-9-minimal-amd64-3"
}

resource "ibm_is_vpc" "satellite_vpc" {
  name           = "${var.is_prefix}-vpc"
  resource_group = data.ibm_resource_group.resource_group.id
}

resource "ibm_is_subnet" "satellite_subnet" {
  count = 3

  name                     = "${var.is_prefix}-subnet-${count.index}"
  vpc                      = ibm_is_vpc.satellite_vpc.id
  total_ipv4_address_count = 256
  zone                     = "${var.ibm_region}-${count.index + 1}"
  resource_group           = data.ibm_resource_group.resource_group.id
}

module "default_sg_rules" {
  source  = "terraform-ibm-modules/vpc/ibm//modules/security-group"
  version = "1.0.0"

  create_security_group = false
  security_group        = ibm_is_vpc.satellite_vpc.default_security_group
  resource_group_id     = data.ibm_resource_group.resource_group.id
  security_group_rules  = local.sg_rules
}

resource "tls_private_key" "example" {
  count     = var.ssh_key_id == null ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "ibm_is_ssh_key" "satellite_ssh" {
  depends_on     = [module.satellite-location]
  count          = var.ssh_key_id == null ? 1 : 0
  name           = "${var.is_prefix}-ssh"
  resource_group = data.ibm_resource_group.resource_group.id
  public_key     = var.public_key != null ? var.public_key : tls_private_key.example[0].public_key_openssh
}

resource "ibm_is_instance" "ibm_host" {
  for_each = local.hosts_flattened

  depends_on     = [module.satellite-location.satellite_location]
  name           = "${var.is_prefix}-host-${each.key}"
  vpc            = ibm_is_vpc.satellite_vpc.id
  zone           = element(local.zones, each.key)
  image          = data.ibm_is_image.rhel7.id
  profile        = each.value.instance_type
  keys           = [var.ssh_key_id != null ? var.ssh_key_id : ibm_is_ssh_key.satellite_ssh[0].id]
  resource_group = data.ibm_resource_group.resource_group.id
  user_data      = module.satellite-location.host_script

  primary_network_interface {
    subnet = element(local.subnet_ids, each.key)
  }
}

resource "ibm_is_floating_ip" "satellite_ip" {
  for_each = local.hosts_flattened

  name           = "${var.is_prefix}-fip-${each.key}"
  target         = ibm_is_instance.ibm_host[each.key].primary_network_interface[0].id
  resource_group = data.ibm_resource_group.resource_group.id
}
