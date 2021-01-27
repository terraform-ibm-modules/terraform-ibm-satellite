module "satellite-cluster-host" {
  source      = "../../modules/cluster_host"

  depends_on            = [ module.satellite-cluster ]
  ibmcloud_api_key      = var.ibmcloud_api_key
  ibm_region            = var.ibm_region
  endpoint              = "cloud.ibm.com"
  resource_group        = var.resource_group
  cluster_name          = var.cluster_name
  location_name         = var.location_name
  host_vm               = element(module.ec2.private_dns, var.host_count)
  host_zone             = "zone-1"
  host_provider         = "aws"
}