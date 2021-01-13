
resource "null_resource" "satellite_location" {
  provisioner "local-exec" {
    when=create
    command = ". ${path.module}/../../modules/location/scripts/location.sh"
    environment = {
      ZONE           = var.zone
      LOCATION       = var.location
      LABEL          = var.label
      API_KEY        = var.ibmcloud_api_key
      REGION         = var.region
      RESOURCE_GROUP = var.resource_group
      PROVIDER       = var.host_provider
      ENDPOINT       = var.endpoint
    }
  }
  provisioner "local-exec" {
    when = destroy
    command = ". ${path.module}/../../modules/location/scripts/destroy.sh"
    environment = {
      LOCATION       = var.location
      API_KEY        = var.ibmcloud_api_key
      REGION         = var.region
      RESOURCE_GROUP = var.resource_group
      PROVIDER       = var.host_provider
      ENDPOINT       = var.endpoint

    }
  }
}

output "satellite_location" {
  value = null_resource.satellite_location
}
