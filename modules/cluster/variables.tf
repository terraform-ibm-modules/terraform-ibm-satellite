#####################################################
# IBM Cloud Satellite -  IBM Example
# Copyright 2021 IBM
#####################################################

variable "create_cluster" {
  description = "Create Cluster: Disable this, not to provision cluster"
  type        = bool
  default     = true
}

variable "cluster" {
  description = "Cluster name"
  type        = string

  validation {
    error_message = "Cluster name must begin and end with a letter and contain only letters, numbers, and - characters."
    condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.cluster))
  }
}

variable "location" {
  description = "Satellite Location Name"
  type        = string
}

variable "kube_version" {
  description = "Kube Version"
  type        = string
}

variable "resource_group" {
  description = "Resource group name that has to be targeted"
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

variable "host_labels" {
  description = "Label to add to attach host script"
  type        = list(string)
}

variable "tags" {
  description = "List of tags associated with this resource."
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