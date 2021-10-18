#####################################################
# IBM Cloud Satellite -  IBM Example
# Copyright 2021 IBM
#####################################################

data "ibm_resource_group" "rg_cluster" {
  name = var.resource_group
}

###################################################################
# Provision openshift cluster
###################################################################
resource "ibm_satellite_cluster" "create_cluster" {
  count = var.create_cluster ? 1 : 0

  name                   = var.cluster
  location               = var.location
  resource_group_id      = data.ibm_resource_group.rg_cluster.id
  enable_config_admin    = true
  kube_version           = var.kube_version
  wait_for_worker_update = (var.wait_for_worker_update ? var.wait_for_worker_update : true)
  worker_count           = (var.worker_count != null ? var.worker_count : null)
  host_labels            = (var.host_labels != null ? var.host_labels : null)

  dynamic "zones" {
    for_each = (var.zones != null ? var.zones : null)
    content {
      id = zones.value
    }
  }

  default_worker_pool_labels = (var.default_worker_pool_labels != null ? var.default_worker_pool_labels : null)
  tags                       = (var.tags != null ? var.tags : null)

  timeouts {
    create = (var.create_timeout != null ? var.create_timeout : null)
    update = (var.update_timeout != null ? var.update_timeout : null)
    delete = (var.delete_timeout != null ? var.delete_timeout : null)
  }

}