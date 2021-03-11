resource "null_resource" "assign_host" {

  lifecycle {
    ignore_changes = [
      triggers,
    ]
  }

  count = var.host_count

  triggers = {
    host_vms_joined = join(",", var.host_vms)
    LOCATION        = var.location_name
    API_KEY         = var.ibmcloud_api_key
    REGION          = var.ibm_region
    RESOURCE_GROUP  = var.resource_group
    ENDPOINT        = var.endpoint
    PROVIDER        = var.host_provider
  }

  provisioner "local-exec" {
    when    = create
    command = ". ${path.module}/scripts/host.sh"

    environment = {
      hostname       = element(var.host_vms, count.index)
      index          = count.index
      LOCATION       = var.location_name
      API_KEY        = var.ibmcloud_api_key
      REGION         = var.ibm_region
      RESOURCE_GROUP = var.resource_group
      ENDPOINT       = var.endpoint
      PROVIDER       = var.host_provider
    }
  }

}

