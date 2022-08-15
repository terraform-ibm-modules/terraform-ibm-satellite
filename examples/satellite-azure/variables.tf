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

variable "worker_image_sku" {
  description = "Operating system image SKU for the workers created"
  type = string
  default = "7-LVM"
}

variable "worker_image_version" {
  description = "Operating system image version for the workers created"
  type = string
  default = "latest"
}
# ##################################################
# # IBM CLOUD Satellite Location Variables
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
  default     = ["eastus-1", "eastus-2", "eastus-3"]
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

##################################################
# IBM CLOUD ROKS Cluster Variables
##################################################

variable "create_cluster" {
  description = "Create Cluster: Disable this, not to provision cluster"
  type        = bool
  default     = true
}

variable "cluster" {
  description = "Satellite Location Name"
  type        = string
  default     = "satellite-azure-cluster"

  validation {
    error_message = "Cluster name must begin and end with a letter and contain only letters, numbers, and - characters."
    condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.cluster))
  }
}

variable "kube_version" {
  description = "Satellite Kube Version"
  default     = "4.10.9_openshift"
}

variable "worker_count" {
  description = "Worker Count for default pool"
  type        = number
  default     = 1
}

variable "wait_for_worker_update" {
  description = "Wait for worker update"
  type        = bool
  default     = true
}

variable "default_worker_pool_labels" {
  description = "Label to add default worker pool"
  type        = map(any)
  default     = null
}

variable "tags" {
  description = "List of tags associated with cluster."
  type        = list(string)
  default     = ["tf", "openshift"]
}

variable "cluster_create_timeout" {
  type        = string
  description = "Timeout duration for create."
  default     = null
}

variable "cluster_update_timeout" {
  type        = string
  description = "Timeout duration for update."
  default     = null
}

variable "cluster_delete_timeout" {
  type        = string
  description = "Timeout duration for delete."
  default     = null
}

##################################################
# IBM CLOUD ROKS Cluster Worker Pool Variables
##################################################
variable "create_cluster_worker_pool" {
  description = "Create Cluster worker pool"
  type        = bool
  default     = false
}

variable "worker_pool_name" {
  description = "Satellite Location Name"
  type        = string
  default     = "satellite-worker-pool"

  validation {
    error_message = "Cluster name must begin and end with a letter and contain only letters, numbers, and - characters."
    condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.worker_pool_name))
  }

}

variable "worker_pool_host_labels" {
  description = "Labels to add to attach host script"
  type        = list(string)
  default     = ["cpu:4", "env:prod", "memory:16266544", "provider:azure"]

  validation {
    condition     = can([for s in var.worker_pool_host_labels : regex("^[a-zA-Z0-9:]+$", s)])
    error_message = "Label must be of the form `key:value`."
  }
}