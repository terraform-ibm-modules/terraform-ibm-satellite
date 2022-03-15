#################################################################################################
# IBMCLOUD & AWS -  Authentication , Target Variables.
# The region variable is common across zones used to setup VSI Infrastructure and Satellite host.
#################################################################################################

variable "TF_VERSION" {
  description = "terraform version"
  type        = string
  default     = "0.13"
}

variable "ibmcloud_api_key" {
  description = "IBM Cloud API Key"
  type        = string
}

variable "aws_access_key" {
  description = "AWS access key"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "resource_group" {
  description = "Name of the resource group on which location has to be created"

  validation {
    condition     = var.resource_group != ""
    error_message = "Sorry, please provide value for resource_group variable."
  }
}

##################################################
# IBMCLOUD Satellite Location Variables
##################################################

variable "location" {
  description = "Location Name"
  default     = "satellite-aws"

  validation {
    condition     = var.location != "" && length(var.location) <= 32
    error_message = "Sorry, please provide value for location_name variable or check the length of name it should be less than 32 chars."
  }
}

variable "is_location_exist" {
  description = "Determines if the location has to be created or not"
  type        = bool
  default     = false
}

variable "managed_from" {
  description = "The IBM Cloud region to manage your Satellite location from. Choose a region close to your on-prem data center for better performance."
  type        = string
  default     = "wdc"
}

variable "location_zones" {
  description = "Allocate your hosts across these three zones"
  type        = list(string)
  default     = []
}

variable "location_bucket" {
  description = "COS bucket name"
  default     = null
}

variable "host_labels" {
  description = "Labels to add to attach host script"
  type        = list(string)
  default     = ["env:prod"]

  validation {
    condition     = can([for s in var.host_labels : regex("^[a-zA-Z0-9:]+$", s)])
    error_message = "Label must be of the form `key:value`."
  }
}

variable "host_provider" {
  description = "The cloud provider of host|vms"
  type        = string
  default     = "aws"
}

##################################################
# AWS EC2 Variables
##################################################
variable "hosts" {
  description = "A map of AWS host objects used to create the location, including instance_type, for_control_plane and count. Control plane count value should always be in multiples of 3, such as 3, 6, 9, or 12 hosts."
  type = map(
    object(
      {
        instance_type     = string
        count             = number
        for_control_plane = bool
      }
    )
  )
  default = {
    0 = {
      instance_type     = "m5d.xlarge"
      count             = 3
      for_control_plane = true
    }
  }

  validation {
    condition     = alltrue([for host in var.hosts : (host.count > 0)])
    error_message = "All hosts must have a count of at least 1."
  }
  validation {
    condition     = alltrue([for host in var.hosts : (host.count % 3 == 0) || !host.for_control_plane])
    error_message = "Count value for all hosts with for_control_plane should always be in multiples of 3, such as 6, 9, or 12 hosts."
  }

  validation {
    condition     = can([for host in var.hosts : host.instance_type])
    error_message = "Each object should have an instance_type."
  }
}

variable "ssh_public_key" {
  description = "SSH Public Key. Get your ssh key by running `ssh-key-gen` command"
  type        = string
  default     = null
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

variable "aws_ami" {
  description = "The AMI to use for ec2 instances"
  type        = string
  default     = "RHEL-7.9_HVM_GA-20200917-x86_64-0-Hourly2-GP2"
}

