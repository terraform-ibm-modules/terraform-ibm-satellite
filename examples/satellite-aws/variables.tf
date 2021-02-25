
#################################################################################################
# IBMCLOUD & AWS -  Authentication , Target Variables.
# The region variable is common across zones used to setup VSI Infrastructure and Satellite host.
#################################################################################################

variable "ibmcloud_api_key" {
  description  = "IBM Cloud API Key"
  type         = string
}

variable "aws_access_key" {
  description  = "AWS access key"
  type         = string
}

variable "aws_secret_key" {
  description  = "AWS secret key"
  type         = string
}

variable "aws_region" {
  description  = "AWS region"
  type         = string
  default      = "us-east-1"
}

variable "ibm_region" {
  description = "Region of the IBM Cloud account. Currently supported regions for satellite are `us-east` and `eu-gb` region."
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

variable "environment" {
  description = "Enter `prod` or `stage` value to run satellite templates on respective environment"
  default     = "prod"

  validation {
    condition     = var.environment == "prod" || var.environment == "stage"
    error_message = "Sorry, please provide correct value for environment variable."
  }
}

##################################################
# IBMCLOUD Satellite Location Variables
##################################################

variable "location_name" {
  description = "Location Name"
  default     = "satellite-aws"

  validation {
    condition     = var.location_name != "" && length(var.location_name) <= 32
    error_message = "Sorry, please provide value for location_name variable or check the length of name it should be less than 32 chars."
  }
}

variable "location_label" {
  description = "Label to create location"
  default     = "prod=true"
}


##################################################
# AWS EC2 Variables
##################################################
variable "satellite_host_count" {
  description    = "The total number of aws host to create for control plane. satellite_host_count value should always be in multiples of 3, such as 3, 6, 9, or 12 hosts"
  type           = number
  default        = 3
  validation {
    condition     = (var.satellite_host_count % 3) == 0 &&  var.satellite_host_count > 0
    error_message = "Sorry, host_count value should always be in multiples of 3, such as 6, 9, or 12 hosts."
  }
}

variable "addl_host_count" {
  description    = "The total number of additional aws host"
  type           = number
  default        = 0
}

variable "instance_type" {
  description    = "The type of aws instance to start, satellite only accepts `m5d.2xlarge` or `m5d.4xlarge` as instance type."
  type           = string
  default        = "m5d.2xlarge"

  validation {
    condition     = var.instance_type == "m5d.2xlarge" || var.instance_type == "m5d.4xlarge"
    error_message = "Sorry, satellite only accepts m5d.2xlarge or m5d.4xlarge as instance type."
  }
}

variable "ssh_public_key" {
  description = "SSH Public Key. Get your ssh key by running `ssh-key-gen` command"
  type        = string
  default     = ""
}

variable "resource_prefix" {
  description = "Name to be used on all aws resource as prefix"
  type        = string
  default     = "satellite-aws"

  validation {
    condition     = var.resource_prefix != "" && length(var.resource_prefix) <= 25
    error_message = "Sorry, please provide value for resource_prefix variable or check the length of resource_prefix it should be less than 25 chars."
  }
}