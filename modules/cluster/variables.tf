
variable "location_name" {
  type         = string
}

variable "cluster_name" {
  type         = string
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
  type        = string
  default     = "Default"
}

variable "ibm_region" {
  description = "Region of the IBM Cloud account"
  type         = string
  default     = "us-east"
}

variable "endpoint" {
    description  = "Endpoint of production/stage environment of IBM Cloud "
    type         = string
    default      = "cloud.ibm.com"
}