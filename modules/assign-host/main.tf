resource "null_resource" "assign_host" {
    depends_on = [var.module_depends_on]
    count = var.ip_count

    provisioner "local-exec" {
        command = ". ${path.module}/../../modules/scripts/03assignhost.sh"
        environment = {
            hostname = "${element(var.host_vm, count.index)}"
            index = count.index
            LOCATION = var.location
            host_zone = var.host_zone
            API_KEY = var.ibmcloud_api_key
            REGION=var.region
            RESOURCE_GROUP=var.resource_group
        }
    }
}

output "assign_host" {
  value = null_resource.assign_host
}