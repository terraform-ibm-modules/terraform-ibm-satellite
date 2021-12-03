#################################################################################################
# IBMCLOUD Authentication and Target Variables.
# The region variable is common across zones used to setup VSI Infrastructure and Satellite host.
#################################################################################################
variable "region" {
  description = "Region of the IBM Cloud account. Currently supported regions for satellite are us-east and eu-gb region."
  default     = "us-east"
}

variable "resource_group" {
  description = "Name of the resource group on which location has to be created"
}

##################################################
# IBMCLOUD Satellite Location and Host Variables
##################################################
variable "location" {
  description = "Location Name"
  default     = "satellite-ibm"

  validation {
    error_message = "Location name must begin and end with a letter and contain only letters, numbers, and - characters."
    condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.location))
  }
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

variable "is_location_exist" {
  description = "Determines if the location has to be created or not"
  type        = bool
  default     = false
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
# IBMCLOUD VPC VSI Variables
##################################################
variable "host_count" {
  description = "The total number of ibm host to create for control plane"
  type        = number
  default     = 3
}

variable "addl_host_count" {
  description = "The total number of additional aws host"
  type        = number
  default     = 3
}

variable "is_prefix" {
  description = "Prefix to the Names of the VPC Infrastructure resources"
  type        = string
  default     = "satellite-ibm"
}

variable "public_key" {
  description = "SSH Public Key. Get your ssh key by running `ssh-key-gen` command"
  type        = string
  default     = null
}

variable "location_profile" {
  description = "Profile information of location hosts"
  type        = string
  default     = "mx2-8x64"
}

variable "cluster_profile" {
  description = "Profile information of Cluster hosts"
  type        = string
  default     = "mx2-8x64"
}

##################################################
# IBMCLOUD ROKS Cluster Variables
##################################################

variable "create_cluster" {
  description = "Create Cluster: Disable this, not to provision cluster"
  type        = bool
  default     = true
}

variable "cluster" {
  description = "Cluster Name"
  type        = string
  default     = "satellite-ibm-cluster"

  validation {
    error_message = "Cluster name must begin and end with a letter and contain only letters, numbers, and - characters."
    condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.cluster))
  }
}

variable "kube_version" {
  description = "Kube Version"
  default     = "4.7_openshift"
}

variable "cluster_host_labels" {
  description = "Labels to add to attach host script"
  type        = list(string)
  default     = ["env:prod"]

  validation {
    condition     = can([for s in var.cluster_host_labels : regex("^[a-zA-Z0-9:]+$", s)])
    error_message = "Label must be of the form `key:value`."
  }
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
  default     = null
}

variable "create_timeout" {
  type        = string
  description = "Timeout duration for create."
  default     = null
}

variable "update_timeout" {
  type        = string
  description = "Timeout duration for update."
  default     = null
}

variable "delete_timeout" {
  type        = string
  description = "Timeout duration for delete."
  default     = null
}

##################################################
# IBMCLOUD ROKS Cluster Worker Pool Variables
##################################################
variable "create_cluster_worker_pool" {
  description = "Create Cluster worker pool"
  type        = bool
  default     = false
}

variable "worker_pool_name" {
  description = "Workerpool name"
  type        = string
  default     = "tf-worker-pool"

  validation {
    error_message = "Cluster name must begin and end with a letter and contain only letters, numbers, and - characters."
    condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.worker_pool_name))
  }

}

variable "worker_pool_host_labels" {
  description = "Labels to add to attach host script"
  type        = list(string)
  default     = ["env:prod"]

  validation {
    condition     = can([for s in var.worker_pool_host_labels : regex("^[a-zA-Z0-9:]+$", s)])
    error_message = "Label must be of the form `key:value`."
  }
}