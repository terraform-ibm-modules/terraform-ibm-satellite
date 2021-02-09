
##################################################
# IBMCLOUD Satellite Location Variables
##################################################

variable "location_name" {
  description = "Location Name"
  type         = string
}

variable "location_label" {
  description = "Label to add to attach host script"
  type         = string
  default     = "prod=true"
}

#################################################################################################
# IBMCLOUD -  Authentication , Target Variables.
#################################################################################################

variable "ibmcloud_api_key" {
  description  = "IBM Cloud API Key"
  type         = string
}

variable "resource_group" {
  description = "Name of the resource group on which location has to be created"

  validation {
    condition     = var.resource_group != ""
    error_message = "Sorry, please provide value for resource_group variable."
  }
}

variable "ibm_region" {
  description = "Region of the IBM Cloud account. Currently supported regions for satellite are us-east and eu-gb region."
  default     = "eu-gb"

  validation {
    condition     = var.ibm_region == "us-east" || var.ibm_region == "eu-gb"
    error_message = "Sorry, satellite only accepts us-east or eu-gb region."
  }
}

variable "host_provider" {
    description  = "The cloud provider of host|vms"
    type         = string
    default      = "aws"
}

variable "endpoint" {
    description  = "Endpoint of production/stage environment of IBM Cloud "
    type         = string
    default      = "cloud.ibm.com"
}