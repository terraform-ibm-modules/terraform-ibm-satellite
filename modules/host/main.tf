resource "ibm_satellite_host" "assign_host" {
  count = var.host_count

  location      = var.location
  host_id       = element(split(".", var.host_vms[count.index]), 0)
  labels        = var.host_labels != null ? var.host_labels : null
  zone          = var.location_zones != null ? element(var.location_zones, count.index) : null
  host_provider = var.host_provider
}
