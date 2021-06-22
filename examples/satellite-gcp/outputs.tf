output "location_id" {
  value = module.satellite-location.location_id
}
output "host_ids" {
  value = google_compute_instance_from_template.gcp_hosts.*.id
}