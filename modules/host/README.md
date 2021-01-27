# This Module is used to assign hosts to the Satellite location control plane.

This module depends on `satellite_location` module..To use this module the hosts in the control plane should be in unassigned state.
 
## Prerequisite

* Set up the IBM Cloud command line interface (CLI), the Satellite plug-in, and other related CLIs.
* Install cli and plugin package
```console
    ibmcloud plugin install container-service
```
## Usage

```
terraform init
```
```
terraform plan
```
```
terraform apply
```
```
terraform destroy
```
## Example Usage
``` hcl

module "satellite-host" {
  source            = "../../modules/host"
  
  module_depends_on = module.ec2
  ip_count          = 3
  host_vm           = module.ec2.private_dns
  location_name     = var.location_name
  host_zone         = var.ibm_region
  ibmcloud_api_key  = var.ibmcloud_api_key
  ibm_region        = var.ibm_region
  endpoint          = "cloud.ibm.com"
  resource_group    = var.resource_group
  host_provider     = "aws"
}
```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name                                  | Description                                                       | Type     | Default | Required |
|---------------------------------------|-------------------------------------------------------------------|----------|---------|----------|
| location_name                         | Name of the Location that has to be created                       | string   | n/a     | yes      |
| resource_group                        | Resource Group Name that has to be targeted.                      | string   | n/a     | yes      |
| ibmcloud_api_key                      | IBM Cloud API Key.                                                | string   | n/a     | yes      |
| ibm_region                            | The location or the region in which VM instance exists.           | string   | n/a     | yes      |
| endpoint                              | Endpoint of production environment of IBM Cloud                   | string   |cloud.ibm.com| yes  |
| host_provider                         | The cloud provider of host/vms.                                   | string   | ibm     | yes      |


<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Note

All optional fields are given value `null` in varaible.tf file. User can configure the same by overwriting with appropriate values.

