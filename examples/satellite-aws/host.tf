#####################################################
# IBM Cloud Satellite -  AWS Example
# Copyright 2021, 2023 IBM
#####################################################

locals {
  // loop through the ec2 map, and make an array of private_dns for control plane hosts
  // could do this as an output in instance.tf too
  ec2_host_names = [for k, v in module.ec2 : v.private_dns]
}

module "satellite-host" {
  //Uncomment following line to point the source to registry level module
  //source = "terraform-ibm-modules/satellite/ibm//modules/host"

  source         = "../../modules/host"
  host_count     = length(local.ec2_host_names)
  location       = module.satellite-location.location_id
  host_vms       = local.ec2_host_names
  location_zones = length(var.location_zones) == 0 ? local.azs : var.location_zones
  host_labels    = var.host_labels
  host_provider  = "aws"
}