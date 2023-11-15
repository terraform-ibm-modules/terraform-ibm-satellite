###########################################################
#  Existing resources and values that need to be supplied #
###########################################################
variable "vcd_user" {
  description = "vCloud Director username"
  default     = "admin"
}

variable "vcd_password" {
  description = "vCloud Director instance password"
  default     = ""
}

variable "vcd_org" {
  description = "vCloud Director organization name/id"
  default     = ""
}

variable "vcd_url" {
  description = "vCloud Director URL"
  default     = "https://daldir01.vmware-solutions.cloud.ibm.com/api"
}

variable "vdc_name" {
  description = "vCloud Director virtual datacenter"
  default     = ""
}

variable "vdc_edge_gateway_name" {
  description = "vCloud Director virtual datacenter edge gateway name"
  default     = ""
}

variable "dhcp_network_name" {
  description = "DHCP network name, connected to edge network. DHCP pools in this network's range should be created on the edge network."
  type        = string
}

variable "rhcos_template_id" {
  description = "ID of RHCOS template to deploy. Default below is 4.12 in the IBM catalog."
  type        = string
  default     = "158d698b-7498-4038-b48d-70665115f4ea"
}

###########################################################
# Satellite location info                                 #
###########################################################
variable "location" {
  description = "Location name if creating via tf, can be ID if is_location_exist is true"
  default     = "satellite-vmware"

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
  description = "Managed from region of Satellite location"
  default     = "wdc"
}

variable "location_zones" {
  description = "Satellite location zones"
  type        = list(string)
  default     = ["zone-1", "zone-2", "zone-3"]
}

variable "host_labels" {
  description = "Optional host labels for Satellite. Can be used to direct hosts to different assignments."
  type        = list(string)
  default     = []
}

variable "resource_group" {
  description = "Resource group of Satellite location"
  type        = string
  default     = "default"
}

###########################################################
#  New VMware resources to be created                     #
###########################################################
variable "vapp_name" {
  description = "vApp to be created"
  type        = string
  default     = "vmware-satellite-vApp"
}

variable "allow_ssh" {
  description = "Set to false to not configure SSH into the VM."
  default     = true
}

variable "ssh_public_key" {
  description = "SSH public key to SSH into VMs for debug. Will be disabled when hosts are assigned."
  type        = string
  default     = ""
}

variable "num_control_plane_hosts" {
  description = "Number of control plane hosts. These will be assigned to the control plane automatically. Specs: 8x32x100"
  type        = number
  default     = 3
}

variable "host_name" {
  description = "Base name of hosts. Will appended with type (cp, worker, stg)"
  type        = string
  default     = "sat-vmw"
}

variable "num_worker_hosts" {
  description = "Number of worker hosts. These can be used for whatever services will run in the location. Specs: 4x16x25&100"
  type        = number
  default     = 0
}

variable "num_storage_hosts" {
  description = "Number of storage hosts. These can be used for storage along with services that will run in the location. Specs: 16x64x25&100&500, configurable below"
  type        = number
  default     = 0
}

### Storage VMs get extra customization ###
variable "storage_vm_cpu" {
  description = "Number of CPUs for storage hosts"
  type        = number
  default     = 16
}
variable "storage_vm_memory" {
  description = "RAM in MB for storage hosts"
  type        = number
  default     = 65536
}
variable "storage_vm_disk0" {
  description = "disk 0 size in MB for storage hosts"
  type        = number
  default     = 25600
}
variable "storage_vm_disk1" {
  description = "disk 1 size in MB for storage hosts"
  type        = number
  default     = 102400
}
variable "storage_vm_disk2" {
  description = "disk 2 size in MB for storage hosts"
  type        = number
  default     = 512000
}
