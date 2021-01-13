module "satellite_location" {
  source            = "../../modules/location"
  zone              = var.location_zone
  location          = var.location_name
  label             = var.labels
  host_provider     = "ibm"
  ibmcloud_api_key  = var.ibmcloud_api_key
  region            = var.region
  resource_group    = var.resource_group
  endpoint          = var.endpoint
}
module "satellite_host" {
  source            = "../../modules/host"
  module_depends_on = ibm_is_instance.satellite_instance
  ip_count          = 3
  host_vm           = ibm_is_instance.satellite_instance[*].name
  location          = var.location_name
  ibmcloud_api_key  = var.ibmcloud_api_key
  region            = var.region
  endpoint          = var.endpoint
  resource_group    = var.resource_group
}
