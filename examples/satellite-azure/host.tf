#####################################################
# IBM Cloud Satellite -  Azure Example
# Copyright 2021 IBM
#####################################################

module "satellite-host" {
  //Uncomment following line to point the source to registry level module
  //source = "terraform-ibm-modules/satellite/ibm//modules/host"

  depends_on     = [azurerm_virtual_machine_data_disk_attachment.disk_attach]
  source         = "../../modules/host"
  host_count     = var.satellite_host_count
  location       = module.satellite-location.location_id
  host_vms       = azurerm_linux_virtual_machine.az_host.*.name
  location_zones = var.location_zones
  host_labels    = var.host_labels
  host_provider  = "azure"
}