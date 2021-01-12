resource "null_resource" "assign_host" {
  depends_on = [var.module_depends_on]
  count      = var.ip_count

  provisioner "local-exec" {
    command = ". ${path.module}/../../modules/host/scripts/host.sh"
    environment = {
      hostname       = "${element(var.host_vm, count.index)}"
      index          = count.index
      LOCATION       = var.location
      host_zone      = var.region
      API_KEY        = var.ibmcloud_api_key
      REGION         = var.region
      RESOURCE_GROUP = var.resource_group
      ENDPOINT       = var.endpoint
    }
  }
  provisioner "local-exec" {
    command = ". ${path.module}/../../modules/host/scripts/destroy.sh"
    environment = {
      hostname       = "${element(var.host_vm, count.index)}"
      LOCATION       = var.location
      API_KEY        = var.ibmcloud_api_key
      REGION         = var.region
      RESOURCE_GROUP = var.resource_group
      ENDPOINT       = var.endpoint
    }
  }
}

output "assign_host" {
  value = null_resource.assign_host
}