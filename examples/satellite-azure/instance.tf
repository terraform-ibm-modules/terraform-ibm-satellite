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
  name     = var.az_resource_group
  location = var.az_region
}

//Module to create security group and security group rules
module "network-security-group" {
  source                = "Azure/network-security-group/azurerm"
  resource_group_name   = azurerm_resource_group.resource_group.name
  location              = azurerm_resource_group.resource_group.location # Optional; if not provided, will use Resource Group location
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
  depends_on = [azurerm_resource_group.resource_group]
}


locals {
  zones   = [1, 2, 3]
}

# module to create vpc, subnets and attach security group to subnet
module "vnet" {
  depends_on          = [azurerm_resource_group.resource_group]
  source              = "Azure/vnet/azurerm"
  resource_group_name = azurerm_resource_group.resource_group.name
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
  depends_on          = [azurerm_resource_group.resource_group]
  count               = var.satellite_host_count+var.addl_host_count
  name                = "${var.az_resource_prefix}-nic-${count.index}"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location

  ip_configuration {
    name                          = "${var.az_resource_prefix}-nic-internal"
    subnet_id                     = element(module.vnet.vnet_subnets, count.index)
    private_ip_address_allocation = "Dynamic"
    primary                       = true
  }
  tags = {
    ibm-satellite = var.az_resource_prefix
  }
}

// Creates Linux Virtual Machines and attaches host to the location..
resource "azurerm_linux_virtual_machine" "az_host" {
  depends_on            = [azurerm_resource_group.resource_group, module.satellite-location]
  count                 = var.satellite_host_count+var.addl_host_count
  name                  = "${var.az_resource_prefix}-vm-${count.index}"
  resource_group_name   = azurerm_resource_group.resource_group.name
  location              = azurerm_resource_group.resource_group.location
  size                  = "Standard_D4s_v3"
  admin_username        = "adminuser"
  custom_data           = base64encode(module.satellite-location.host_script) 
  network_interface_ids = [azurerm_network_interface.az_nic[count.index].id]

  zone = element(local.zones, count.index)
  admin_ssh_key {
    username   = "adminuser"
    public_key = var.ssh_public_key
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 128
  }
  source_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "7-LVM"
    version   = "latest"
  }
}

// There was no issue while creating and attaching hosts to the location using `azurerm_linux_virtual_machine_scale_set` resource..
// But we had to avoid this resource as we dont have a way to get details of vms that are been created in scale set..
// There is neither a datasource that lists vm details of scaleset nor this resource gives any details..
// We need vm details in order to assign hosts using `ibm_satellite_host` resource and hence we had to shift to azurerm_linux_virtual_machine resource


# resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
#   name                = "sat-vmss" //variable
#   computer_name_prefix="az-vm"
#   resource_group_name = azurerm_resource_group.resource_group.name
#   location            = azurerm_resource_group.resource_group.location
#   instances           = 4
#   admin_username      = "adminuser"
# sku              = "Standard_D4s_v3"
# zones           = [ "1","2","3",]
# admin_ssh_key {
#   username   = "adminuser"
#   public_key = file("~/.ssh/id_rsa.pub") //variable
# }
# #source_image_id="RedHat:RHEL:7.8:7.8.2020111309"
# source_image_reference {
#   publisher = "RedHat"
#   offer     = "RHEL"
#   sku       = "7.8"
#   version   = "7.8.2020111309"
# }
# custom_data= data.local_file.file.content_base64
# os_disk {
#       caching                   = "ReadWrite"
#       storage_account_type      = "Premium_LRS"
#   }
# data_disk {
#       caching                   = "None"
#       disk_size_gb              = 64
#       lun = 0
#       storage_account_type      = "Premium_LRS"
#   }
# network_interface {
#   name    = "sat-nic-01" //variable
#   primary = true
#   network_security_group_id=module.network-security-group.network_security_group_id

#   ip_configuration {
#     name      = "sat-nic-o1-defaultIpConfiguration" 
#     primary   = true
#     subnet_id = module.vnet.vnet_subnets[0]
#     version    = "IPv4"
#   }
# }
# }
