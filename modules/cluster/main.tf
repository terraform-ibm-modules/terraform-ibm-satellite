resource "null_resource" "create_cluster" {

  triggers = {
      cluster_name   = var.cluster_name
      API_KEY        = var.ibmcloud_api_key
      REGION         = var.ibm_region
      RESOURCE_GROUP = var.resource_group
      ENDPOINT       = var.endpoint
  }


  provisioner "local-exec" {
    when = create
    command = ". ${path.module}/../../modules/cluster/scripts/cluster.sh"
    environment = {
      LOCATION       = var.location_name
      cluster_name   = var.cluster_name
      API_KEY        = var.ibmcloud_api_key
      REGION         = var.ibm_region
      RESOURCE_GROUP = var.resource_group
      ENDPOINT       = var.endpoint
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = ". ${path.module}/../../modules/cluster/scripts/destroy.sh"
    environment = {
      cluster_name   = self.triggers.cluster_name
      API_KEY        = self.triggers.API_KEY
      REGION         = self.triggers.REGION
      RESOURCE_GROUP = self.triggers.RESOURCE_GROUP
      ENDPOINT       = self.triggers.ENDPOINT
    }
  }


}
