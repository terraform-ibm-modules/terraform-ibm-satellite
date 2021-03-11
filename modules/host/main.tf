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
      hostname       = element(split(",", self.triggers.host_vms_joined), count.index)
      index          = count.index
      LOCATION       = self.triggers.LOCATION
      API_KEY        = self.triggers.API_KEY
      REGION         = self.triggers.REGION
      RESOURCE_GROUP = self.triggers.RESOURCE_GROUP
      ENDPOINT       = self.triggers.ENDPOINT
      PROVIDER       = self.triggers.PROVIDER
    }
  }

  provisioner "local-exec" {
    when    = destroy
    command = ". ${path.module}/scripts/destroy.sh"

    environment = {
      hostname       = element(split(",", self.triggers.host_vms_joined), count.index)
      LOCATION       = self.triggers.LOCATION
      API_KEY        = self.triggers.API_KEY
      REGION         = self.triggers.REGION
      RESOURCE_GROUP = self.triggers.RESOURCE_GROUP
      ENDPOINT       = self.triggers.ENDPOINT
    }
  }
}

