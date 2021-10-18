#####################################################
# IBM Cloud Satellite -  IBM Example
# Copyright 2021 IBM
#####################################################

provider "ibm" {
  region = var.region
}

###################################################################
# Create satellite location
###################################################################
module "satellite-location" {
  source            = "terraform-ibm-modules/satellite/ibm//modules/location"
  is_location_exist = var.is_location_exist
  location          = var.location
  managed_from      = var.managed_from
  location_zones    = local.location_zones
  location_bucket   = var.location_bucket
  host_labels       = var.host_labels
  ibm_region        = var.region
  resource_group    = var.resource_group
  host_provider     = "ibm"
}

###################################################################
# Assign host to satellite location control plane
###################################################################
module "satellite-host" {
  source         = "terraform-ibm-modules/satellite/ibm//modules/host"
  host_count     = var.host_count
  location       = module.satellite-location.location_id
  host_vms       = ibm_is_instance.satellite_instance[*].name
  location_zones = local.location_zones
  host_labels    = var.host_labels
  host_provider  = "ibm"
}

###################################################################
# Create satellite ROKS cluster
###################################################################
module "satellite-cluster" {
  //Uncomment following line to point the source to registry level module
  //source = "git::git@github.com:terraform-ibm-modules/terraform-ibm-satellite.git//modules/cluster"

  source                     = "./modules/cluster"
  create_cluster             = var.create_cluster
  cluster                    = var.cluster
  location                   = module.satellite-location.location_id
  kube_version               = var.kube_version
  zones                      = local.location_zones
  resource_group             = var.resource_group
  worker_count               = var.worker_count
  host_labels                = var.cluster_host_labels
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
  //source = "terraform-ibm-modules/satellite/ibm//modules/configure-cluster-worker-pool"

  source                     = "./modules/configure-cluster-worker-pool"
  create_cluster_worker_pool = var.create_cluster_worker_pool
  worker_pool_name           = var.worker_pool_name
  cluster                    = var.cluster
  zones                      = local.location_zones
  resource_group             = var.resource_group
  kube_version               = var.kube_version
  worker_count               = var.worker_count
  host_labels                = var.worker_pool_host_labels
  create_timeout             = var.create_timeout
  delete_timeout             = var.delete_timeout
  depends_on                 = [module.satellite-cluster]
}