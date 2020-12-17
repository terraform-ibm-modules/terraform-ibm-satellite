variable "name" {
  description = "Name to be used on all resources as prefix"
  type        = string
}

variable "instance_count" {
  description = "Number of instances to launch"
  type        = number
  default     = 1
}

variable "ami" {
  description = "ID of AMI to use for the instance"
  type        = string
}

variable "placement_group" {
  description = "The Placement Group to start the instance in"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "The type of instance to start"
  type        = string
}

variable "key_name" {
  description = "The ssh key name to use for the instance"
  type        = string
}

variable "input_file_name" {
  description = "Input satellite attach host script."
  type        = string
}

variable "vpc_security_group_ids" {
  description = "A list of security group IDs to associate with"
  type        = list(string)
  default     = null
}

variable "subnet_id" {
  description = "The VPC Subnet ID to launch in"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "A list of VPC Subnet IDs to launch in"
  type        = list(string)
  default     = []
}

variable "associate_public_ip_address" {
  description = "If true, the EC2 instance will have associated public IP address"
  type        = bool
  default     = null
}

variable "private_ip" {
  description = "Private IP address to associate with the instance in a VPC"
  type        = string
  default     = null
}

variable "private_ips" {
  description = "A list of private IP address to associate with the instance in a VPC. Should match the number of instances."
  type        = list(string)
  default     = []
}

variable "user_data" {
  description = "The user data to provide when launching the instance. Do not pass gzip-compressed data via this argument; see user_data_base64 instead."
  type        = string
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "root_block_device" {
  description = "Customize details about the root block device of the instance. See Block Devices below for details"
  type        = list(map(string))
  default     = []
}

variable "ebs_block_device" {
  description = "Additional EBS block devices to attach to the instance"
  type        = list(map(string))
  default     = []
}

