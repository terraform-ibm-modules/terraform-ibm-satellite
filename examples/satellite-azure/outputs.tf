output "location_id" {
  value = module.satellite-location.location_id
}
output "host_ids" {
  value = [for host in azurerm_linux_virtual_machine.az_host : host.id]
}