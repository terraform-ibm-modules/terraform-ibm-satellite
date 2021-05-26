
resource "null_resource" "satellite_location" {

  lifecycle {
    ignore_changes = [
      triggers,
    ]
  }

  triggers = {
    LOCATION       = var.location_name
    API_KEY        = var.ibmcloud_api_key
    REGION         = var.ibm_region
    RESOURCE_GROUP = var.resource_group
    ENDPOINT       = var.endpoint
    PROVIDER       = var.host_provider
    DEBUG_CLI      = var.debug_cli
  }

  provisioner "local-exec" {
    when    = create
    command = ". ${path.module}/scripts/location.sh"

    environment = {
      LOCATION       = var.location_name
      LABEL          = var.location_label
      API_KEY        = var.ibmcloud_api_key
      REGION         = var.ibm_region
      RESOURCE_GROUP = var.resource_group
      PROVIDER       = var.host_provider
      ENDPOINT       = var.endpoint
      ADDHOST_PATH   = path.module
      DEBUG_CLI      = var.debug_cli
    }
  }

  provisioner "local-exec" {
    when    = destroy
    command = ". ${path.module}/scripts/destroy.sh"

    environment = {
      LOCATION       = self.triggers.LOCATION
      API_KEY        = self.triggers.API_KEY
      REGION         = self.triggers.REGION
      RESOURCE_GROUP = self.triggers.RESOURCE_GROUP
      ENDPOINT       = self.triggers.ENDPOINT
      DEBUG_CLI      = self.triggers.DEBUG_CLI
    }
  }
}

output "satellite_location" {
  value = null_resource.satellite_location
}

output "module_id" {
  value = null_resource.satellite_location.id
}

output "addhost_path" {
  value = "${path.module}/addhost.sh"
}
