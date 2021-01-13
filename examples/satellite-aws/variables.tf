
##################################################
# IBMCLOUD Satellite Location Variables
##################################################

variable "location_name" {
    description  =  "Name of the satellite location on which cluster has to be created | attached"
}

variable "location_zone" {
  description  = "zone of the staellite location"
  default      = "wdc06"
}

variable "label" {
  description  =  "Host labels"
  default      =  "env=dev"
}

#################################################################################################
# IBMCLOUD & AWS -  Authentication , Target Variables.
# The region variable is common across zones used to setup VSI Infrastructure and Satellite host.
#################################################################################################

variable "ibmcloud_api_key" { 
  description  = "IBM Cloud API Key"
  type         = string
}

variable "endpoint" {
  default = "cloud.ibm.com"
}

variable "aws_region" {
  description  = "AWS region"
  type         = string
  default      = "eu-west-1"
}

variable "aws_access_key" {
  description  = "AWS access key"
  type         = string
}

variable "aws_secret_key" {
  description  = "AWS secret key"
  type         = string
}

variable "region" {
  description = "Location Region"
  type        = string
  default     = "us-south"
}

variable "resource_group" {
  description = "Resoure Group"
  type        = string
  default     = "default"
}

##################################################
# AWS EC2 Variables
##################################################

variable "ami" {
  description  = "AWS ami ID"
  type         = string
   default     = "ami-065ec1e661d619058"
}

variable "instance_type" {
  description = "AWS EC2 Instance type"
  type        = string
  default     = "m5d.2xlarge"
}

variable "vm_prefix" {
  description = "Name to be used on all VMs as prefix"
  type        = string
  default     = "sat"
}

variable "volume_size" {
  description = "Volume size of instance"
  type        = number
  default     = 10
}

variable "key_name" {
  description  = "Number of instances to launch"
  type         = string
  default      = "aws_ssh_key"
}

variable "ssh_public_key" {
  description  = "SSH public key"
  type         = string
}

variable "instance_count" {
  description = "Number of instances to launch"
  type        = number
  default     = 3
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {"env": "aws"}
}

##################################################
# Assign Host Variables
##################################################

variable "assign_host_count" {
  type        = number
  default     = 3
}

variable "host_zone" {
  default = "us-east"
}