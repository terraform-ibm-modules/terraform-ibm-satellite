variable "location" {
  description = "Satellite Location Name"
  type        = string
}

variable "host_labels" {
  description = "Host labels to assign host to control plane "
  type        = list(string)
  default     = null

  validation {
    condition     = can([for s in var.host_labels : regex("^[a-zA-Z0-9:]+$", s)])
    error_message = "Label must be of the form `key:value`."
  }
}

variable "location_zones" {
  description = "Allocate your hosts across these three zones"
  type        = list(string)
  default     = null
}

variable "host_vms" {
  description = "A list of hostnames to attach for setting up location control plane."
  type        = list(string)
  default     = []
}

variable "host_count" {
  description = "The total number of ibm/aws host to create for control plane"
  type        = number
  default     = 3

}

variable "host_provider" {
  description = "The cloud provider of host/vms"
  type        = string
  default     = "ibm"
}