##################################################
# IBMCLOUD Satellite Location and Host Variables
##################################################
variable "location_name" {
  description = "Location Name"
  default     = "satellite-ibm"

  validation {
    condition     = var.location_name != "" && length(var.location_name) <= 32
    error_message = "Sorry, please provide value for location_name variable or check the length of name it should be less than 32 chars."
  }
}
variable "location_label" {
  description = "Label to create location"
  default     = "prod=true"
}

#################################################################################################
# IBMCLOUD Authentication and Target Variables.
# The region variable is common across zones used to setup VSI Infrastructure and Satellite host.
#################################################################################################

variable "ibmcloud_api_key" {
  description = "IBM Cloud API Key"
}
variable "ibm_region" {
  description = "Region of the IBM Cloud account. Currently supported regions for satellite are us-east and eu-gb region."
  default     = "us-east"

  validation {
    condition     = var.ibm_region == "us-east" || var.ibm_region == "eu-gb"
    error_message = "Sorry, satellite only accepts `us-east` or `eu-gb` region."
  }
}
variable "resource_group" {
  description = "Name of the resource group on which location has to be created"

  validation {
    condition     = var.resource_group != ""
    error_message = "Sorry, please provide value for resource_group variable."
  }
}

variable "environment" {
  description = "Select prod or stage environemnet to run satellite templates"
  default     = "prod"

  validation {
    condition     = var.environment == "prod" || var.environment == "stage"
    error_message = "Sorry, please provide correct value for environment variable."
  }
}

##################################################
# IBMCLOUD VPC VSI Variables
##################################################
variable "host_count" {
  description    = "The total number of ibm host to create for control plane"
  type           = number
  default        = 3

  validation {
    condition     = (var.host_count % 3) == 0 &&  var.host_count > 0
    error_message = "Sorry, host_count value should always be in multiples of 3, such as 6, 9, or 12 hosts."
  }
}

variable "addl_host_count" {
  description    = "The total number of additional aws host"
  type           = number
  default        = 0
}

variable "is_prefix" {
  description = "Prefix to the Names of the VPC Infrastructure resources"
  type        = string
  default     ="ibm-satellite"
}
variable "public_key" {
  description  = "SSH Public Key. Get your ssh key by running `ssh-key-gen` command"
  type         = string
  default      = ""
}
