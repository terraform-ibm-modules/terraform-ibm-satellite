#####################################################
# IBM Cloud Satellite -  IBM
# Copyright 2021 IBM
#####################################################

output "worker_pool_id" {
  value = var.create_cluster_worker_pool ? concat(ibm_satellite_cluster_worker_pool.create_cluster_wp.*.id, [""])[0] : ""
}

output "worker_pool_worker_count" {
  value = var.create_cluster_worker_pool ? concat(ibm_satellite_cluster_worker_pool.create_cluster_wp.*.worker_count, [""])[0] : ""
}

output "worker_pool_zones" {
  value = var.create_cluster_worker_pool ? [for wp in ibm_satellite_cluster_worker_pool.create_cluster_wp : wp.zones] : []
}

output "worker_pool_host_labels" {
  value = var.create_cluster_worker_pool ? [for wp in ibm_satellite_cluster_worker_pool.create_cluster_wp : wp.host_labels] : []
}