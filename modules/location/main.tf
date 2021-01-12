
resource "null_resource" "satellite_location" {
  depends_on = [var.module_depends_on]
  provisioner "local-exec" {
    command = ". ${path.module}/../../modules/scripts/location.sh"
    environment = {
    ZONE = var.zone
    LOCATION = var.location
    LABEL = var.label
    API_KEY = var.ibmcloud_api_key
    REGION=var.region
    RESOURCE_GROUP=var.resource_group
    PROVIDER=var.host_provider
    # COS_KEY = var.cos_key
    # COS_KEY_ID = var.cos_key_id
    }
  }
}

output "satellite_location" {
  value = null_resource.satellite_location
}
