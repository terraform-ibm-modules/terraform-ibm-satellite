#####################################################
# IBM Cloud Satellite -  IBM Example
# Copyright 2021 IBM
#####################################################

###################################################################
# Assign host to satellite location control plane
###################################################################
module "satellite-host" {
  //Uncomment following line to point the source to registry level module
  //source = "terraform-ibm-modules/satellite/ibm//modules/host"

  source         = "../../modules/host"
  host_count     = var.host_count
  location       = module.satellite-location.location_id
  host_vms       = ibm_is_instance.satellite_instance[*].name
  location_zones = var.location_zones
  host_labels    = var.host_labels
  host_provider  = "ibm"
}