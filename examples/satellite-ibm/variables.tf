
variable "zone" {
  description="zone of the staellite location"
  default = "wdc06"
}

variable "location" {
  description="Location Name"
  default ="jan-2021"
}

variable "label" {
  description="Label to create location"
  default = "prod=true"
}
variable "module_depends_on" {
  default ="test"
}
variable "ibmcloud_api_key" {
    description="IBM Cloud API Key"
    
}
variable "host_provider" {
  description="Provider of the hosts that are been attached to the satellite"
}

variable "region" {
    description="Region of the IBM Cloud account"
    default="us-east"
}
variable "resource_group" {
    description="Name of the resource group on which location has to be created"
    default="Default"
}


