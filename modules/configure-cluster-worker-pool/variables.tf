#####################################################
# IBM Cloud Satellite -  IBM Example
# Copyright 2021 IBM
#####################################################

variable "create_cluster_worker_pool" {
  description = "Create Cluster worker pool"
  type        = bool
  default     = false
}

variable "worker_pool_name" {
  type        = string
  description = "Worker pool Name"

  validation {
    error_message = "Worker pool name must begin and end with a letter and contain only letters, numbers, and - characters."
    condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.worker_pool_name))
  }
}

variable "cluster" {
  type        = string
  description = "Cluster Name"

  validation {
    error_message = "Cluster name must begin and end with a letter and contain only letters, numbers, and - characters."
    condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.cluster))
  }
}

variable "kube_version" {
  type        = string
  description = "Satellite Kube Version"
}

variable "resource_group" {
  description = "Resource Group Name that has to be targeted"
  type        = string
}

variable "zones" {
  type    = list(string)
  default = null
}

variable "worker_count" {
  description = "Worker Count for default pool"
  type        = number
  default     = 1
}

variable "workerpool_labels" {
  description = "worker pool labels"
  type        = map(any)
  default     = null
}

variable "host_labels" {
  description = "Label to add to attach host script"
  type        = list(string)
}

variable "tags" {
  description = "List of tags associated with this resource."
  type        = list(string)
  default     = null
}

variable "entitlement" {
  description = "openshift cluster entitlement"
  type        = string
  default     = null
}

variable "disk_encryption" {
  description = "Disk encryption for worker node"
  type        = string
  default     = null
}

variable "isolation" {
  description = "Isolation for the worker node"
  type        = string
  default     = null
}

variable "flavor" {
  description = "Worker node flavor"
  type        = string
  default     = null
}

variable "create_timeout" {
  type        = string
  description = "Timeout duration for create."
  default     = null
}

variable "delete_timeout" {
  type        = string
  description = "Timeout duration for delete."
  default     = null
}