data "ibm_resource_group" "res_group" {
  name = var.resource_group
}	
module "satellite-location" {
  source            = "../../modules/location"

  is_location_exist   = var.is_location_exist
  location            = var.location
  managed_from        = var.managed_from
  location_zones      = var.location_zones
  host_labels         = var.host_labels
  ibmcloud_api_key    = var.ibmcloud_api_key
  ibm_region          = var.ibm_region
  resource_group_id   = data.ibm_resource_group.res_group.id
  host_provider       = "ibm"
}