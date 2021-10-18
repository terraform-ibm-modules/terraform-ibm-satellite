#####################################################
# IBM Cloud Satellite -  IBM
# Copyright 2021 IBM
#####################################################

output "cluster_id" {
  value = var.create_cluster ? concat(ibm_satellite_cluster.create_cluster.*.id, [""])[0] : ""
}

output "cluster_crn" {
  value = var.create_cluster ? concat(ibm_satellite_cluster.create_cluster.*.crn, [""])[0] : ""
}

output "server_url" {
  value = var.create_cluster ? concat(ibm_satellite_cluster.create_cluster.*.master_url, [""])[0] : ""
}

output "cluster_state" {
  value = var.create_cluster ? concat(ibm_satellite_cluster.create_cluster.*.state, [""])[0] : ""
}

output "cluster_status" {
  value = var.create_cluster ? concat(ibm_satellite_cluster.create_cluster.*.master_status, [""])[0] : ""
}

output "ingress_hostname" {
  value = var.create_cluster ? concat(ibm_satellite_cluster.create_cluster.*.ingress_hostname, [""])[0] : ""
}