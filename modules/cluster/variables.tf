
variable "location_name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "availability_zones" {
  description = "List of availability zones names in the region"
  type        = list(string)
  default     = []
  validation {
    condition     = length(var.availability_zones) >= 3
    error_message = "You must have at least 3 availability_zones."
  }
}

#################################################################################################
# IBMCLOUD -  Authentication , Target Variables.
#################################################################################################

variable "ibmcloud_api_key" {
  description = "IBM Cloud API Key"
  type        = string
}

variable "resource_group" {
  description = "Name of the resource group on which location has to be created"

  validation {
    condition     = var.resource_group != ""
    error_message = "Sorry, please provide value for resource_group variable."
  }
}

variable "ibm_region" {
  description = "Region of the IBM Cloud account"
  type        = string
  default     = "us-east"
}

variable "endpoint" {
  description = "Endpoint of production/stage environment of IBM Cloud "
  type        = string
  default     = "cloud.ibm.com"
}

variable "host_zones" {
  type = string
}
