#####################################################
# IBM Cloud Satellite -  AWS Example
# Copyright 2021 IBM
#####################################################

module "satellite-host" {
  //Uncomment following line to point the source to registry level module
  //source = "terraform-ibm-modules/satellite/ibm//modules/host"

  source         = "../../modules/host"
  host_count     = var.satellite_host_count
  location       = module.satellite-location.location_id
  host_vms       = module.ec2.private_dns
  location_zones = length(var.location_zones) == 0 ? local.azs : var.location_zones
  host_labels    = var.host_labels
  host_provider  = "aws"
}