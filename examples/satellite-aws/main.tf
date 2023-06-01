#####################################################
# IBM Cloud Satellite -  AWS Example
# Copyright 2021 IBM
#####################################################

module "satellite-location" {
  //Uncomment following line to point the source to registry level module
  //source = "terraform-ibm-modules/satellite/ibm//modules/location"

  source            = "../../modules/location"
  is_location_exist = var.is_location_exist
  location          = var.location
  managed_from      = var.managed_from
  location_zones    = local.azs
  location_bucket   = var.location_bucket
  host_labels       = var.host_labels
  resource_group    = var.resource_group
  host_provider     = "aws"
  custom_script     = "if [[ \"$${OPERATING_SYSTEM}\" == \"RHEL7\" ]]; then\n\tyum update -y\n\tyum-config-manager --enable '*'\n\tyum install container-selinux -y\nfi\n"
}