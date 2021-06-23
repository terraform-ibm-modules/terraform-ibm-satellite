output "location_id" {
  value = module.satellite-location.location_id
}
output "gcp_host_links" {
  value = module.gcp_hosts.instances_self_links
}
output "gcp_host_names" {
  value = local.hosts
}