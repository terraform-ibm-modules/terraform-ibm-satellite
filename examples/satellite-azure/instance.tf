#####################################################
# IBM Cloud Satellite -  Azure Example
# Copyright 2021 IBM
#####################################################

/*
This template uses following
Modules:
  Azure/network-security-group/azurerm - Security group and Security group rules
  Azure/vnet/azurerm                   - vpc, subnets, Attach security group to subnets
Resources: (Using these resources because no standard azure module was found that meets our requirement)
  azurerm_resource_group                - Resource Group
  azurerm_network_interface             - Network interfaces for the Azure Instance
  azurerm_linux_virtual_machine         - Linux Virtual Machines, Attaches host to the Satellite location
*/


// Azure Resource Group
resource "azurerm_resource_group" "resource_group" {
  count    = var.is_az_resource_group_exist == false ? 1 : 0
  name     = var.az_resource_group
  location = var.az_region
}
data "azurerm_resource_group" "resource_group" {
  name       = var.is_az_resource_group_exist == false ? azurerm_resource_group.resource_group.0.name : var.az_resource_group
  depends_on = [azurerm_resource_group.resource_group]
}


//Module to create security group and security group rules
module "network-security-group" {
  source                = "Azure/network-security-group/azurerm"
  resource_group_name   = data.azurerm_resource_group.resource_group.name
  location              = data.azurerm_resource_group.resource_group.location # Optional; if not provided, will use Resource Group location
  security_group_name   = "${var.az_resource_prefix}-sg"
  source_address_prefix = ["*"]
  custom_rules = [
    {
      name                       = "ssh"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "description-myssh"
    },
    {
      name                       = "satellite"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "80,443,30000-32767"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "description-http"
    },
  ]
  tags = {
    ibm-satellite = var.az_resource_prefix
  }
  depends_on = [data.azurerm_resource_group.resource_group]
}

# module to create vpc, subnets and attach security group to subnet
module "vnet" {
  depends_on          = [data.azurerm_resource_group.resource_group]
  source              = "Azure/vnet/azurerm"
  resource_group_name = data.azurerm_resource_group.resource_group.name
  vnet_name           = "${var.az_resource_prefix}-vpc"
  address_space       = ["10.0.0.0/16"]
  subnet_prefixes     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  subnet_names        = ["${var.az_resource_prefix}-subnet-1", "${var.az_resource_prefix}-subnet-2", "${var.az_resource_prefix}-subnet-3"]
  nsg_ids = {
    "${var.az_resource_prefix}-subnet-1" = module.network-security-group.network_security_group_id
    "${var.az_resource_prefix}-subnet-2" = module.network-security-group.network_security_group_id
    "${var.az_resource_prefix}-subnet-3" = module.network-security-group.network_security_group_id
  }

  tags = {
    ibm-satellite = var.az_resource_prefix
  }
}

// Creates network interface for the subnets that are been created
resource "azurerm_network_interface" "az_nic" {
  depends_on          = [data.azurerm_resource_group.resource_group]
  for_each            = local.hosts_flattened
  name                = "${var.az_resource_prefix}-nic-${each.key}"
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = data.azurerm_resource_group.resource_group.location

  ip_configuration {
    name                          = "${var.az_resource_prefix}-nic-internal"
    subnet_id                     = element(module.vnet.vnet_subnets, each.key)
    private_ip_address_allocation = "Dynamic"
    primary                       = true
  }
  tags = {
    ibm-satellite = var.az_resource_prefix
  }
}
resource "tls_private_key" "rsa_key" {
  count     = (var.ssh_public_key == null ? 1 : 0)
  algorithm = "RSA"
  rsa_bits  = 4096
}

// Creates Linux Virtual Machines and attaches host to the location..
resource "azurerm_linux_virtual_machine" "az_host" {
  depends_on            = [data.azurerm_resource_group.resource_group, module.satellite-location]
  for_each              = local.hosts_flattened
  name                  = "${var.az_resource_prefix}-vm-${each.key}"
  resource_group_name   = data.azurerm_resource_group.resource_group.name
  location              = data.azurerm_resource_group.resource_group.location
  size                  = each.value.instance_type
  admin_username        = "adminuser"
  custom_data           = base64encode(module.satellite-location.host_script)
  network_interface_ids = [azurerm_network_interface.az_nic[each.key].id]

  zone = each.value.zone
  admin_ssh_key {
    username   = "adminuser"
    public_key = var.ssh_public_key != null ? var.ssh_public_key : tls_private_key.rsa_key.0.public_key_openssh
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 128
  }
  source_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = var.worker_image_sku
    version   = var.worker_image_version
  }
}
resource "azurerm_managed_disk" "data_disk" {
  for_each             = local.hosts_flattened
  name                 = "${var.az_resource_prefix}-disk-${each.key}"
  location             = data.azurerm_resource_group.resource_group.location
  resource_group_name  = data.azurerm_resource_group.resource_group.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 128
  zones                = [each.value.zone]
}

resource "azurerm_virtual_machine_data_disk_attachment" "disk_attach" {
  for_each           = local.hosts_flattened
  managed_disk_id    = azurerm_managed_disk.data_disk[each.key].id
  virtual_machine_id = azurerm_linux_virtual_machine.az_host[each.key].id
  lun                = "10"
  caching            = "ReadWrite"
}
