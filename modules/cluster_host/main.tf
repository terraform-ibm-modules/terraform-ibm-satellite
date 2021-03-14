resource "null_resource" "assign_host_to_cluster" {

  lifecycle {
    ignore_changes = [
      triggers,
    ]
  }

  triggers = {
    API_KEY        = var.ibmcloud_api_key
    REGION         = var.ibm_region
    RESOURCE_GROUP = var.resource_group
    ENDPOINT       = var.endpoint

    location     = var.location_name
    cluster_name = var.cluster_name
    hostname     = var.host_vm
    zone         = var.host_zone
    PROVIDER     = var.host_provider
  }

  provisioner "local-exec" {
    when    = create
    command = ". ${path.module}/../../modules/cluster_host/scripts/assign_cluster_host.sh"
    environment = {
      API_KEY        = var.ibmcloud_api_key
      REGION         = var.ibm_region
      RESOURCE_GROUP = var.resource_group
      ENDPOINT       = var.endpoint

      location     = var.location_name
      cluster_name = var.cluster_name
      hostname     = var.host_vm
      zone         = var.host_zone
      PROVIDER     = var.host_provider
    }
  }

  provisioner "local-exec" {
    when    = destroy
    command = ". ${path.module}/../../modules/cluster_host/scripts/destroy.sh"
    environment = {
      API_KEY        = self.triggers.ibmcloud_api_key
      REGION         = self.triggers.ibm_region
      RESOURCE_GROUP = self.triggers.resource_group
      ENDPOINT       = self.triggers.endpoint

      location     = self.triggers.location_name
      cluster_name = self.triggers.cluster_name
      hostname     = self.triggers.host_vm
      zone         = self.triggers.host_zone
      PROVIDER     = self.triggers.host_provider
    }
  }

}
