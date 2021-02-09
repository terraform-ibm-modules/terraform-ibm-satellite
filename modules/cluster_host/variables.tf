#################################################################################################
# IBMCLOUD -  Authentication , Target Variables.
#################################################################################################

variable "ibmcloud_api_key" {
  description  = "IBM Cloud API Key"
  type         = string
}

variable "ibm_region" {
  description  = "Region of the IBM Cloud account"
  type         = string
  default      = "us-east"
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
# IBMCLOUD -  satellite Variables.
#################################################################################################

variable "location_name" {
   type = string
}

variable "cluster_name" {
  type  = string
}

variable "host_vm" {
  type  = string
}

variable "host_zone" {
    type         = string
    default      = "zone-1"
}

variable "host_provider" {
  type         = string
  default      = "aws"
}