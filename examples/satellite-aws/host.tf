module "satellite-host" {
  source            = "../../modules/host"

  host_count        = var.satellite_host_count
  location          = module.satellite-location.location_id
  host_vms          = module.ec2.private_dns
  location_zones    = length(var.location_zones) == 0 ? local.azs : var.location_zones
  host_labels       = var.host_labels
  host_provider     = "aws"
}