#################################################################################################
# IBMCLOUD -  Authentication , Target Variables.
#################################################################################################

variable "resource_group" {
  description = "Name of the resource group on which location has to be created"
}

variable "ibm_region" {
  description = "Region of the IBM Cloud account. Currently supported regions for satellite are us-east and eu-gb region."
  default     = null
}

#################################################
# IBMCLOUD Satellite Location Variables
##################################################

variable "location" {
  description = "Location Name"
  type        = string
}

variable "is_location_exist" {
  description = "Location Name"
  type        = bool
  default     = false
}

variable "coreos_enabled" {
  description = "CoreOS-enabled location. Supports RHEL8 and CoreOS hosts."
  type        = bool
  default     = false
}

variable "managed_from" {
  description = "The IBM Cloud region to manage your Satellite location from. Choose a region close to your on-prem data center for better performance."
  type        = string
}

variable "location_zones" {
  description = "Allocate your hosts across these three zones"
  type        = list(string)
  default     = null
}

variable "host_labels" {
  description = "Labels to add to attach host script"
  type        = list(string)
  default     = null

  validation {
    condition     = can([for s in var.host_labels : regex("^[a-zA-Z0-9:]+$", s)])
    error_message = "Label must be of the form `key:value`."
  }
}

variable "location_bucket" {
  description = "COS bucket name"
  default     = null
}

variable "host_provider" {
  description = "The cloud provider of host|vms"
  type        = string
  default     = "ibm"
}

variable "coreos_host" {
  description = "Set to true if hosts will use CoreOS. Used for attachment script, worker pools, etc"
  type        = bool
  default     = false
}

variable "custom_script" {
  description = "Custom script to insert into host attach script. Can be used for OS configuration/preparation. This will override whatever the provider inserts based on host_provider."
  type        = string
  default     = null
}