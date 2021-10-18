#####################################################
# IBM Cloud Satellite -  IBM
# Copyright 2021 IBM
#####################################################

output "location_id" {
  value = module.satellite-location.location_id
}

output "host_script" {
  value = module.satellite-location.host_script
}

output "host_ids" {
  value = ibm_is_instance.satellite_instance.*.id
}

output "floating_ip_ids" {
  value = ibm_is_floating_ip.satellite_ip.*.id
}

output "floating_ip_addresses" {
  value = ibm_is_floating_ip.satellite_ip.*.address
}

output "vpc" {
  value = ibm_is_vpc.satellite_vpc.id
}

output "default_security_group" {
  value = ibm_is_vpc.satellite_vpc.default_security_group
}

output "subnets" {
  value = ibm_is_subnet.satellite_subnet.*.id
}

output "cluster_id" {
  value = var.create_cluster ? module.satellite-cluster.cluster_id : ""
}

output "cluster_crn" {
  value = var.create_cluster ? module.satellite-cluster.cluster_crn : ""
}

output "server_url" {
  value = var.create_cluster ? module.satellite-cluster.server_url : ""
}

output "cluster_state" {
  value = var.create_cluster ? module.satellite-cluster.cluster_state : ""
}

output "cluster_status" {
  value = var.create_cluster ? module.satellite-cluster.cluster_status : ""
}

output "ingress_hostname" {
  value = var.create_cluster ? module.satellite-cluster.ingress_hostname : ""
}

output "cluster_worker_pool_id" {
  value = var.create_cluster_worker_pool ? module.satellite-cluster-worker-pool.worker_pool_id : ""
}

output "worker_pool_worker_count" {
  value = var.create_cluster_worker_pool ? module.satellite-cluster-worker-pool.worker_pool_worker_count : ""
}

output "worker_pool_zones" {
  value = var.create_cluster_worker_pool ? module.satellite-cluster-worker-pool.worker_pool_zones : []
}