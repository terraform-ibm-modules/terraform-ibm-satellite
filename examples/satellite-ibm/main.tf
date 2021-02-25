module "satellite-location" {
  source            = "../../modules/location"
  location_name     = var.location_name
  location_label    = var.location_label
  host_provider     = "ibm"
  ibmcloud_api_key  = var.ibmcloud_api_key
  ibm_region        = var.ibm_region
  resource_group    = var.resource_group
  endpoint          = var.environment == "prod" ? "cloud.ibm.com" : "test.cloud.ibm.com"
}

module "satellite-host" {
  source            = "../../modules/host"
  depends_on        = [ ibm_is_instance.satellite_instance ]
  host_count        = var.host_count
  host_vms          = ibm_is_instance.satellite_instance[*].name
  location_name     = var.location_name
  ibmcloud_api_key  = var.ibmcloud_api_key
  ibm_region        = var.ibm_region
  endpoint          = var.environment == "prod" ? "cloud.ibm.com" : "test.cloud.ibm.com"
  resource_group    = var.resource_group
}
