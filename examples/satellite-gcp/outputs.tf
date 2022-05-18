output "location_id" {
  value = module.satellite-location.location_id
}
output "gcp_host_links" {
  value = [for host in module.gcp_hosts : host.instances_self_links]
}
output "gcp_host_names" {
  value = flatten([for host in module.gcp_hosts : [for instance in host.instances_details : instance.name]])
}