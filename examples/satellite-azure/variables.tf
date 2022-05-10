
# ##################################################
# # Azure and IBM Authentication Variables
# ##################################################

variable "TF_VERSION" {
  description = "terraform version"
  type        = string
  default     = "0.13"
}

variable "subscription_id" {
  description = "Subscription id of Azure Account"
  type        = string
}
variable "client_id" {
  description = "Client id of Azure Account"
  type        = string
}
variable "tenant_id" {
  description = "Tenent id of Azure Account"
  type        = string
}
variable "client_secret" {
  description = "Client Secret of Azure Account"
  type        = string
}
variable "is_az_resource_group_exist" {
  default     = false
  description = "If false, resource group (az_resource_group) will be created. If true, existing resource group (az_resource_group) will be read"
  type        = bool
}

variable "az_resource_group" {
  description = "Name of the resource Group"
  type        = string
  default     = "satellite-azure"
}
variable "az_region" {
  description = "Azure Region"
  type        = string
  default     = "eastus"
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

# ##################################################
# # Azure Resources Variables
# ##################################################

variable "az_resource_prefix" {
  description = "Name to be used on all Azure resources as prefix"
  type        = string
  default     = "satellite-azure"
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.az_resource_prefix))
    error_message = "Variable az_resource_prefix should always be lowercase alphanumeric, and may contain hyphens."
  }
}
variable "ssh_public_key" {
  description = "SSH Public Key. Get your ssh key by running `ssh-key-gen` command"
  type        = string
  default     = null
}
variable "instance_type" {
  description = "The type of Azure instance to start"
  type        = string
  default     = null
}
variable "satellite_host_count" {
  description = "The total number of Azure host to create for control plane. "
  type        = number
  default     = null
  validation {
    condition     = var.satellite_host_count == null || ((can((var.satellite_host_count % 3) == 0)) && can(var.satellite_host_count > 0))
    error_message = "Sorry, host_count value should always be in multiples of 3, such as 6, 9, or 12 hosts."
  }
}
variable "addl_host_count" {
  description = "The total number of additional Azure vms"
  type        = number
  default     = null
}

variable "cp_hosts" {
  description = "A map of Azure host objects used to create the location control plane, including instance_type and count. Control plane count value should always be in multiples of 3, such as 3, 6, 9, or 12 hosts."
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
      instance_type = "Standard_D4as_v4"
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
  description = "A list of Azure host objects used for provisioning services on your location after setup, including instance_type and count."
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

# ##################################################
# # IBMCLOUD Satellite Location Variables
# ##################################################

variable "location" {
  description = "Location Name"
  default     = "satellite-azure"

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
  default     = ["us-east-1", "us-east-2", "us-east-3"]
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
