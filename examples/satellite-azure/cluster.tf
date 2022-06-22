#####################################################
# IBM Cloud Satellite -  Azure Example
# Copyright 2022 IBM
#####################################################

###################################################################
# Create satellite ROKS cluster
###################################################################
module "satellite-cluster" {
  source = "terraform-ibm-modules/satellite/ibm//modules/cluster"

  depends_on                 = [module.satellite-host]
  create_cluster             = var.create_cluster
  cluster                    = var.cluster
  zones                      = var.location_zones
  location                   = module.satellite-location.location_id
  resource_group             = var.ibm_resource_group
  kube_version               = var.kube_version
  worker_count               = var.worker_count
  host_labels                = var.host_labels
  tags                       = var.tags
  default_worker_pool_labels = var.default_worker_pool_labels
  create_timeout             = var.cluster_create_timeout
  update_timeout             = var.cluster_update_timeout
  delete_timeout             = var.cluster_delete_timeout
}

###################################################################
# Create worker pool on existing ROKS cluster
###################################################################
module "satellite-cluster-worker-pool" {
  source = "terraform-ibm-modules/satellite/ibm//modules/configure-cluster-worker-pool"

  depends_on                 = [module.satellite-cluster]
  create_cluster_worker_pool = var.create_cluster_worker_pool
  worker_pool_name           = var.worker_pool_name
  cluster                    = var.cluster
  zones                      = var.location_zones
  resource_group             = var.ibm_resource_group
  kube_version               = var.kube_version
  worker_count               = var.worker_count
  host_labels                = var.worker_pool_host_labels
  create_timeout             = var.cluster_create_timeout
  delete_timeout             = var.cluster_delete_timeout
}