module "satellite-host" {
  source = "../../modules/host"

  host_count     = var.satellite_host_count
  location       = module.satellite-location.location_id
  host_vms       = azurerm_linux_virtual_machine.az_host.*.name
  location_zones = var.location_zones
  host_labels    = var.host_labels
  host_provider  = "azure"
}