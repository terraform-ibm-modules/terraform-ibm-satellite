
# ##################################################
# # Azure and IBM Authentication Variables
# ##################################################

variable "subscription_id" {
  description = "Subscription id of Azure Account"
  type        = string
}
variable "client_id" {
  description = "Client id of Azure Account"
  type        = string
}
variable "tenant_id" {
  description = "Tenent id of Azure Account"
  type        = string
}
variable "client_secret" {
  description = "Client Secret of Azure Account"
  type        = string
}
variable "az_resource_group" {
  description = "Name of the resource Group"
  type        = string
}
variable "az_region" {
  description = "Azure Region"
  type        = string
}
variable "ibmcloud_api_key" {
  description  = "IBM Cloud API Key"
  type         = string
}
variable "ibm_region" {
  description = "Region of the IBM Cloud account. Currently supported regions for satellite are `us-east` and `eu-gb` region."
  default     = "us-east"
  validation {
    condition     = var.ibm_region == "us-east" || var.ibm_region == "eu-gb"
    error_message = "Sorry, satellite only accepts us-east or eu-gb region."
  }
}
variable "ibm_resource_group" {
  description = "Region of the IBM Cloud account. Currently supported regions for satellite are `us-east` and `eu-gb` region."
  type        = string
}

# ##################################################
# # Azure Resources Variables
# ##################################################

variable "az_resource_prefix" {
  description = "Name to be used on all azure resources as prefix"
  type        = string
  default     = "satellite-azure"
}
variable "ssh_public_key" {
  description = "SSH Public Key. Get your ssh key by running `ssh-key-gen` command"
  type        = string
}
variable "satellite_host_count" {
  description = "The total number of Azure host to create for control plane. "
  type        = number
  default     = 3
  validation {
    condition     = (var.satellite_host_count % 3) == 0 && var.satellite_host_count > 0
    error_message = "Sorry, host_count value should always be in multiples of 3, such as 6, 9, or 12 hosts."
  }
}
variable "addl_host_count" {
  description = "The total number of additional aws host"
  type        = number
  default     = 0
}

# ##################################################
# # IBMCLOUD Satellite Location Variables
# ##################################################

variable "location" {
  description = "Location Name"
  default     = "satellite-azure"

  validation {
    condition     = var.location != "" && length(var.location) <= 32
    error_message = "Sorry, please provide value for location_name variable or check the length of name it should be less than 32 chars."
  }
}
variable "is_location_exist" {
  description = "Determines if the location has to be created or not"
  type        = bool
  default     = false
}

variable "managed_from" {
  description = "The IBM Cloud region to manage your Satellite location from. Choose a region close to your on-prem data center for better performance."
  type        = string
  default     = "wdc"
}

variable "location_zones" {
  description = "Allocate your hosts across these three zones"
  type        = list(string)
  default     = ["us-east-1", "us-east-2", "us-east-3"]
}

variable "location_bucket" {
  description = "COS bucket name"
  default     = ""
}

variable "host_labels" {
  description = "Labels to add to attach host script"
  type        = list(string)
  default     = ["env:prod"]

  validation {
    condition     = can([for s in var.host_labels : regex("^[a-zA-Z0-9:]+$", s)])
    error_message = "Label must be of the form `key:value`."
  }
}
