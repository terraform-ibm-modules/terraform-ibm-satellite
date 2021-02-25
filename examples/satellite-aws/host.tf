module "satellite-host" {
  source            = "../../modules/host"
  
  depends_on        = [ module.ec2 ]
  host_count        = var.satellite_host_count
  host_vms          = module.ec2.private_dns
  location_name     = var.location_name
  ibmcloud_api_key  = var.ibmcloud_api_key
  ibm_region        = var.ibm_region
  endpoint          = var.environment == "prod" ? "cloud.ibm.com" : "test.cloud.ibm.com"
  resource_group    = var.resource_group
  host_provider     = "aws"
}