module "satellite-host" {
  source            = "../../modules/host"
  module_depends_on = module.ec2
  ip_count          = var.assign_host_count
  host_vm           = module.ec2.private_dns
  location          = var.location_name
  host_zone         = var.host_zone
  ibmcloud_api_key  = var.ibmcloud_api_key
  region            = var.region
  endpoint          = var.endpoint
  resource_group    = var.resource_group
  host_provider     = "aws"
}