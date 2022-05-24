#####################################################
# IBM Cloud Satellite -  Azure Example
# Copyright 2022 IBM
#####################################################

###################################################################
# Create satellite ROKS cluster
###################################################################
module "satellite-cluster" {
  //Uncomment following line to point the source to registry level module
  source = "terraform-ibm-modules/satellite/ibm//modules/cluster"

  # source                     = "../../modules/cluster"
  create_cluster             = var.create_cluster
  cluster                    = var.cluster
  zones                      = var.location_zones
  location                   = module.satellite-location.location_id
  resource_group             = var.resource_group
  kube_version               = var.kube_version
  worker_count               = var.worker_count
  host_labels                = var.host_labels
  tags                       = var.tags
  default_worker_pool_labels = var.default_worker_pool_labels
  create_timeout             = var.create_timeout
  update_timeout             = var.update_timeout
  delete_timeout             = var.delete_timeout
  depends_on                 = [module.satellite-host]
}

###################################################################
# Create worker pool on existing ROKS cluster
###################################################################
module "satellite-cluster-worker-pool" {
  //Uncomment following line to point the source to registry level module
  source = "terraform-ibm-modules/satellite/ibm//modules/configure-cluster-worker-pool"

  # source                     = "../../modules/configure-cluster-worker-pool"
  create_cluster_worker_pool = var.create_cluster_worker_pool
  worker_pool_name           = var.worker_pool_name
  cluster                    = var.cluster
  zones                      = var.location_zones
  resource_group             = var.resource_group
  kube_version               = var.kube_version
  worker_count               = var.worker_count
  host_labels                = var.worker_pool_host_labels
  create_timeout             = var.create_timeout
  delete_timeout             = var.delete_timeout
  depends_on                 = [module.satellite-cluster]
}