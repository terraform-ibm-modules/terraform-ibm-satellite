#####################################################
# IBM Cloud Satellite -  IBM Example
# Copyright 2021, 2023 IBM
#####################################################

provider "ibm" {
  region = var.ibm_region
}

###################################################################
# Create satellite location
###################################################################
module "satellite-location" {
  //Uncomment following line to point the source to registry level module
  //source = "terraform-ibm-modules/satellite/ibm//modules/location"

  source            = "../../modules/location"
  is_location_exist = var.is_location_exist
  location          = var.location
  coreos_enabled    = var.coreos_enabled_location
  managed_from      = var.managed_from
  location_zones    = var.location_zones
  location_bucket   = var.location_bucket
  host_labels       = var.host_labels
  ibm_region        = var.ibm_region
  resource_group    = var.resource_group
  host_provider     = "ibm"
  coreos_host       = var.coreos_host
}