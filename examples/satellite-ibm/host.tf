#####################################################
# IBM Cloud Satellite -  IBM Example
# Copyright 2021 IBM
#####################################################

###################################################################
# Assign host to satellite location control plane
###################################################################
module "satellite-host" {
  //Uncomment following line to point the source to registry level module
  //source = "terraform-ibm-modules/satellite/ibm//modules/host"

  for_each = local.hosts

  source     = "../../modules/host"
  host_count = each.value.for_control_plane ? each.value.count : 0
  location   = module.satellite-location.location_id
  host_vms = [for count_index in range(
    sum([for index, host in local.hosts : index < each.key ? host.count : 0]), // starting ID
    sum([for index, host in local.hosts : index <= each.key ? host.count : 0]) // starting ID + current IDs count
    ) :
    ibm_is_instance.ibm_host[count_index].name
  ]
  location_zones = var.location_zones
  host_labels    = var.host_labels
  host_provider  = "ibm"
}