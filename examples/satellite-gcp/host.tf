module "satellite-host" {
  depends_on     = [google_compute_instance_from_template.gcp_hosts]
  source         = "../../modules/host"
  host_count     = var.satellite_host_count
  location       = module.satellite-location.location_id
  host_vms       = google_compute_instance_from_template.gcp_hosts.*.name
  location_zones = var.location_zones
  host_labels    = var.host_labels
  host_provider  = "google"
}