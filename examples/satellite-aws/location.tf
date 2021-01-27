
module "satellite-location" {
  source            = "../../modules/location"

  location_name     = var.location_name
  location_label    = var.location_label
  ibmcloud_api_key  = var.ibmcloud_api_key
  ibm_region        = var.ibm_region
  endpoint          = "cloud.ibm.com"
  resource_group    = var.resource_group
  host_provider     = "aws"
}