resource "null_resource" "assign_host_to_cluster" {
  
  triggers = {
      cluster_name   = var.cluster_name
      hostname       = var.host_vm
      location       = var.location_name
      API_KEY        = var.ibmcloud_api_key
      REGION         = var.ibm_region
      RESOURCE_GROUP = var.resource_group
      ENDPOINT       = var.endpoint
      PROVIDER       = var.host_provider
  }

  provisioner "local-exec" {
    when = create
    command = ". ${path.module}/../../modules/cluster_host/scripts/assign_cluster_host.sh"
    environment = {
    API_KEY        = var.ibmcloud_api_key
    REGION         = var.ibm_region
    RESOURCE_GROUP = var.resource_group
    ENDPOINT       = var.endpoint
    hostname       = var.host_vm
    location       = var.location_name
    cluster_name   = var.cluster_name
    zone           = var.host_zone
    PROVIDER       = var.host_provider
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = ". ${path.module}/../../modules/cluster_host/scripts/destroy.sh"
    environment = {
      hostname       = self.triggers.hostname
      PROVIDER       = self.triggers.PROVIDER
      location       = self.triggers.location
      API_KEY        = self.triggers.API_KEY
      REGION         = self.triggers.REGION
      RESOURCE_GROUP = self.triggers.RESOURCE_GROUP
      ENDPOINT       = self.triggers.ENDPOINT
    }
  }

}