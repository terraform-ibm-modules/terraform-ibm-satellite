
module "satellite-location" {
  source            = "../../modules/location"
  zone              = var.location_zone
  location          = var.location_name
  label             = var.label
  ibmcloud_api_key  = var.ibmcloud_api_key
  region            = var.region
  endpoint          = var.endpoint
  resource_group    = var.resource_group
  host_provider     = "aws"
}
