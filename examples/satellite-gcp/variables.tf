
# # ##################################################
# # # GCP and IBM Authentication Variables
# # ##################################################

variable "gcp_project" {
  description = "GCP Project ID"
  type        = string
}
variable "gcp_region" {
  description = "Google Region"
  type        = string
  default     = "us-east1"
}
variable "gcp_credentials" {
  description = "Either the path to or the contents of a service account key file in JSON format."
  type        = string
}
variable "ibmcloud_api_key" {
  description = "IBM Cloud API Key"
  type        = string
}
variable "ibm_resource_group" {
  description = "Resource group name of the IBM Cloud account."
  type        = string
  default     = "default"
}

# # ##################################################
# # # Google Resources Variables
# # ##################################################

variable "gcp_resource_prefix" {
  description = "Name to be used on all gcp resource as prefix"
  type        = string
  default     = "satellite-google"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,25}$", var.gcp_resource_prefix))
    error_message = "Sorry, gcp_resource_prefix must be between 1 and 25 characters, contain uppercase or lowercase characters, numbers, or hyphens."
  }
}
variable "satellite_host_count" {
  description = "The total number of GCP host to create for control plane. satellite_host_count value should always be in multiples of 3, such as 3, 6, 9, or 12 hosts"
  type        = number
  default     = null
  validation {
    condition     = var.satellite_host_count == null || ((can((var.satellite_host_count % 3) == 0)) && can(var.satellite_host_count > 0))
    error_message = "Sorry, host_count value should always be in multiples of 3, such as 6, 9, or 12 hosts."
  }
}
variable "addl_host_count" {
  description = "The total number of additional gcp host"
  type        = number
  default     = null
}
variable "instance_type" {
  description = "The type of gcp instance to start."
  type        = string
  default     = null
}
variable "cp_hosts" {
  description = "A map of GCP host objects used to create the location control plane, including instance_type and count. Control plane count value should always be in multiples of 3, such as 3, 6, 9, or 12 hosts."
  type = list(
    object(
      {
        instance_type = string
        count         = number
      }
    )
  )
  default = [
    {
      instance_type = "n2-standard-4"
      count         = 3
    }
  ]

  validation {
    condition     = ! contains([for host in var.cp_hosts : (host.count > 0)], false)
    error_message = "All hosts must have a count of at least 1."
  }
  validation {
    condition     = ! contains([for host in var.cp_hosts : (host.count % 3 == 0)], false)
    error_message = "Count value for all hosts should always be in multiples of 3, such as 6, 9, or 12 hosts."
  }

  validation {
    condition     = can([for host in var.cp_hosts : host.instance_type])
    error_message = "Each object should have an instance_type."
  }
}

variable "addl_hosts" {
  description = "A list of GCP host objects used for provisioning services on your location after setup, including instance_type and count."
  type = list(
    object(
      {
        instance_type = string
        count         = number
      }
    )
  )
  default = []
  validation {
    condition     = ! contains([for host in var.addl_hosts : (host.count > 0)], false)
    error_message = "All hosts must have a count of at least 1."
  }

  validation {
    condition     = can([for host in var.addl_hosts : host.instance_type])
    error_message = "Each object should have an instance_type."
  }
}
variable "ssh_public_key" {
  description = "SSH Public Key. Get your ssh key by running `ssh-key-gen` command"
  type        = string
  default     = null
}
variable "gcp_ssh_user" {
  description = "SSH User of above provided ssh_public_key"
  type        = string
  default     = null
}
# # ##################################################
# # # IBMCLOUD Satellite Location Variables
# # ##################################################

variable "location" {
  description = "Location Name"
  default     = "satellite-gcp"

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
  default     = ["us-east1-b", "us-east1-c", "us-east1-d"]
}

variable "location_bucket" {
  description = "COS bucket name"
  default     = ""
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

variable "TF_VERSION" {
  description = "Terraform version"
  type        = string
  default     = "0.13"
}
