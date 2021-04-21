module "satellite-location" {
  source = "../../modules/location"

  is_location_exist = var.is_location_exist
  location          = var.location
  managed_from      = var.managed_from
  location_zones    = var.location_zones
  host_labels       = var.host_labels
  ibm_region        = var.ibm_region
  resource_group    = var.ibm_resource_group
  host_provider     = "azure"
  ibmcloud_api_key  = ""
}
