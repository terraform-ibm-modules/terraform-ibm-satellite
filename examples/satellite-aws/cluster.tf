module "satellite-cluster" {
  source                = "../../modules/cluster"
 
  depends_on            = [ module.satellite-host ]
  location_name         = var.location_name
  cluster_name          = var.cluster_name
  ibmcloud_api_key      = var.ibmcloud_api_key
  ibm_region            = var.ibm_region
  endpoint              = "cloud.ibm.com"
  resource_group        = var.resource_group
}