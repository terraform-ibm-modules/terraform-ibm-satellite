module "satellite_location" {
  source            = "../../modules/location"
  module_depends_on = var.module_depends_on
  zone              = var.zone
  location          = var.location
  label             = var.label
  host_provider=var.host_provider
  ibmcloud_api_key=var.ibmcloud_api_key
  region=var.region
  resource_group=var.resource_group
}

# module "assign_host" {
#   source            = "../../modules/assign-host"
#   module_depends_on = module.attach_host.attach_host
#   ip_count          = var.assign_host_count
#   host_vm           = module.vms.host_vm_names
#   location          = var.location
#   host_zone= var.host_zone
#   ibmcloud_api_key=var.ibmcloud_api_key
#   region=var.region
#   resource_group=var.resource_group
# }

# resource "ibm_is_vpc" "testacc_vpc" {
#   name = var.vpc
# }

# data "ibm_resource_group" "resource_group" {
#   name = "Default"
# }

# module "instance" {
#   source = "terraform-ibm-modules/vpc/ibm//modules/instance"
#   name                      = var.name
#   vpc_id                    = ibm_is_vpc.testacc_vpc.id
#   resource_group_id         = data.ibm_resource_group.resource_group.id
#   location                  = var.instance_location
#   image                     = var.image
#   profile                   = var.profile
#   ssh_keys                  = var.ssh_keys
#   primary_network_interface = var.primary_network_interface
#   user_data                 = (var.user_data != null ? var.user_data : null)
#   boot_volume               = (var.boot_volume != null ? var.boot_volume : null)
#   network_interfaces        = (var.network_interfaces != null ? var.network_interfaces : null)
#   data_volumes              = (var.data_volumes != null ? var.data_volumes : [])
#   tags                      = (var.tags != null ? var.tags : [])
# }
# variable "name" {
#   description = "Name of the Instance"
#   type        = string
# }

# variable "vpc" {
#   description = "VPC name"
#   type        = string
#   default ="satellite-vpc"
# }

# variable "instance_location" {
#   description = "Instance zone"
#   type        = string
# }

# variable "image" {
#   description = "Image ID for the instance"
#   type        = string
#   default="r006-ed3f775f-ad7e-4e37-ae62-7199b4988b00"
# }

# variable "profile" {
#   description = "Profile type for the Instance"
#   type        = string
#   default="cx2-2x4"
# }

# variable "ssh_keys" {
#   description = "List of ssh key IDs to the instance"
#   type        = list(string)
# }

# variable "primary_network_interface" {
#   description = "List of primary_network_interface that are to be attached to the instance"
#   type = list(object({
#     subnet               = string
#     interface_name       = string
#     security_groups      = list(string)
#     primary_ipv4_address = string
#   }))
# }

# #####################################################
# # Optional Parameters
# #####################################################

# variable "resource_group" {
#   description = "Resource group name"
#   type        = string
#   default     = "default"
# }

# variable "user_data" {
#   description = "User Data for the instance"
#   type        = string
#   default     = null
# }

# variable "data_volumes" {
#   description = "List of volume ids that are to be attached to the instance"
#   type        = list(string)
#   default     = null
# }

# variable "tags" {
#   description = "List of Tags for the vpc"
#   type        = list(string)
#   default     = null
# }

# variable "network_interfaces" {
#   description = "List of network_interfaces that are to be attached to the instance"
#   type = list(object({
#     subnet               = string
#     interface_name       = string
#     security_groups      = list(string)
#     primary_ipv4_address = string
#   }))
#   default = null
# }

# variable "boot_volume" {
#   description = "List of boot volume that are to be attached to the instance"
#   type = list(object({
#     name       = string
#     encryption = string
#   }))
#   default     = null
# }
