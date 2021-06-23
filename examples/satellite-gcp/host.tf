module "satellite-host" {
  depends_on     = [module.gcp_hosts]
  source         = "../../modules/host"
  host_count     = var.satellite_host_count
  location       = module.satellite-location.location_id
  host_vms       = local.hosts
  location_zones = var.location_zones
  host_labels    = var.host_labels
  host_provider  = "google"
}

locals {
  hosts = [for instance in module.gcp_hosts.instances_details : instance.name]
}