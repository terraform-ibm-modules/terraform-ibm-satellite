##################################################
# IBMCLOUD Satellite Location and Host Variables
##################################################
variable "location_name" {
  description = "Location Name"
  default     = "satellite-ibm"
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
variable "endpoint" {
  default = "cloud.ibm.com"
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
  default     = "Default"
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
variable "is_prefix" {
  description = "Prefix to the Names of the VPC Infrastructure resources"
  type        = string
  default="ibm-satellite-vsi"
}
variable "public_key" {
  description="SSH Public Key. Get your ssh key by running `ssh-key-gen` command"
  type = string
}