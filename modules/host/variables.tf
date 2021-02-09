
#################################################################################################
# IBMCLOUD -  Authentication , Target Variables.
#################################################################################################

variable "ibmcloud_api_key" {
  description  = "IBM Cloud API Key"
  type         = string
}

variable "ibm_region" {
  description = "Region of the IBM Cloud account. Currently supported regions for satellite are us-east and eu-gb region."
  default     = "us-east"

  validation {
    condition     = var.ibm_region == "us-east" || var.ibm_region == "eu-gb"
    error_message = "Sorry, satellite only accepts us-east or eu-gb region."
  }
}

variable "resource_group" {
  description = "Name of the resource group on which location has to be created"

  validation {
    condition     = var.resource_group != ""
    error_message = "Sorry, please provide value for resource_group variable."
  }
}

variable "endpoint" {
    description  = "Endpoint of production/stage environment of IBM Cloud "
    type         = string
    default      = "cloud.ibm.com"
}

#################################################################################################
# IBMCLOUD -  satellite variables
#################################################################################################

variable "location_name" {
  description = "Satellite Location Name"
  type         = string
}

variable "host_vms" {
   description  = "A list of hostnames to attach for setting up location control plane."
  type          = list(string)
  default       = []
}

variable "host_count" {
  description    = "The total number of ibm/aws host to create for control plane"
  type           = number
  default        = 3

  validation {
    condition     = (var.host_count % 3) == 0 &&  var.host_count > 0
    error_message = "Sorry, host_count value should always be multiple of 3."
  }
}

variable "host_provider" {
    description  = "The cloud provider of host/vms"
    type         = string
    default      = "aws"
}