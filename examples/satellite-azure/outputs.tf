output "location_id" {
  value = module.satellite-location.location_id
}
output "host_ids" {
  value = azurerm_linux_virtual_machine.az_host.*.id
}