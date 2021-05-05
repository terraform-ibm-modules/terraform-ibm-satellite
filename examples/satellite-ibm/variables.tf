#################################################################################################
# IBMCLOUD Authentication and Target Variables.
# The region variable is common across zones used to setup VSI Infrastructure and Satellite host.
#################################################################################################
variable "ibm_region" {
  description = "Region of the IBM Cloud account. Currently supported regions for satellite are us-east and eu-gb region."
  default     = "us-east"
}

variable "resource_group" {
  description = "Name of the resource group on which location has to be created"
}

##################################################
# IBMCLOUD Satellite Location and Host Variables
##################################################
variable "location" {
  description = "Location Name"
  default     = "satellite-ibm"
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
  default     = null
}

variable "is_location_exist" {
  description = "Determines if the location has to be created or not"
  type        = bool
  default     = false
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

##################################################
# IBMCLOUD VPC VSI Variables
##################################################
variable "host_count" {
  description = "The total number of ibm host to create for control plane"
  type        = number
  default     = 3
}

variable "addl_host_count" {
  description = "The total number of additional aws host"
  type        = number
  default     = 0
}

variable "is_prefix" {
  description = "Prefix to the Names of the VPC Infrastructure resources"
  type        = string
  default     = "satellite-ibm"
}

variable "public_key" {
  description = "SSH Public Key. Get your ssh key by running `ssh-key-gen` command"
  type        = string
  default     = null
}
