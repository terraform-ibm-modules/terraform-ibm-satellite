provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
}
data "ibm_resource_group" "resource_group" {
  name = var.resource_group
}
resource "ibm_is_vpc" "satellite_vpc" {
  name = "${var.is_prefix}-vpc"
}
resource "ibm_is_subnet" "satellite_subnet" {
  count                    = 3
  name                     = "${var.is_prefix}-subnet-${count.index}"
  vpc                      = ibm_is_vpc.satellite_vpc.id
  total_ipv4_address_count = 256
  zone                     = "${var.region}-${count.index + 1}"
}
resource "ibm_is_ssh_key" "satellite_ssh" {
  name       = "${var.is_prefix}-ssh"
  public_key = var.public_key
}
resource "ibm_is_instance" "satellite_instance" {
  depends_on     = [module.satellite_location.satellite_location]
  count          = 3
  name           = "${var.is_prefix}-instance-${count.index}"
  vpc            = ibm_is_vpc.satellite_vpc.id
  zone           = "${var.region}-${count.index + 1}"
  image          = "r014-931515d2-fcc3-11e9-896d-3baa2797200f"
  profile        = "mx2-8x64"
  keys           = [ibm_is_ssh_key.satellite_ssh.id]
  resource_group = data.ibm_resource_group.resource_group.id
  user_data      = file(replace("${path.module}/addhost.sh*${module.satellite_location.module_id}", "/[*].*/", ""))
  primary_network_interface {
    subnet = ibm_is_subnet.satellite_subnet[count.index].id
  }
}
resource "ibm_is_floating_ip" "satellite_ip" {
  count  = 3
  name   = "${var.is_prefix}-fip-${count.index}"
  target = ibm_is_instance.satellite_instance[count.index].primary_network_interface[0].id
}
