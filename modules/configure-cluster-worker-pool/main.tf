#####################################################
# IBM Cloud Satellite -  IBM Example
# Copyright 2021 IBM
#####################################################

data "ibm_resource_group" "rg_wp" {
  name = var.resource_group
}

###################################################################
# Read openshift cluster
###################################################################
data "ibm_satellite_cluster" "read_cluster" {
  count = var.create_cluster_worker_pool ? 1 : 0
  name  = var.cluster
}

###################################################################
# Provision openshift cluster worker pool
###################################################################
resource "ibm_satellite_cluster_worker_pool" "create_cluster_wp" {
  count = var.create_cluster_worker_pool ? 1 : 0

  name               = var.worker_pool_name
  cluster            = data.ibm_satellite_cluster.read_cluster.0.id
  resource_group_id  = data.ibm_resource_group.rg_wp.id
  worker_count       = (var.worker_count != null ? var.worker_count : null)
  host_labels        = (var.host_labels != null ? var.host_labels : null)
  worker_pool_labels = (var.workerpool_labels != null ? var.workerpool_labels : null)

  dynamic "zones" {
    for_each = var.zones
    content {
      id = zones.value
    }
  }

  entitlement     = (var.entitlement != null ? var.entitlement : null)
  disk_encryption = (var.disk_encryption != null ? var.disk_encryption : null)
  isolation       = (var.isolation != null ? var.isolation : null)
  flavor          = (var.flavor != null ? var.flavor : null)

  timeouts {
    create = (var.create_timeout != null ? var.create_timeout : null)
    delete = (var.delete_timeout != null ? var.delete_timeout : null)
  }

}