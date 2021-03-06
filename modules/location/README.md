# This Module is used to create satellite location and generate attach host script.

This module `creates satellite location` for the specified zone|location|region and `generates script` named addhost.sh in the home directory by performing attach host.The generated script is used by `ibm_is_instance` resource or AWS EC2 module as `user_data` attribute and runs the script. At this stage all the VMs that has run addhost.sh will be attached to the satellite location and will be in unassigned state.

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
module "satellite-location" {
  source = "../../modules/location"

  is_location_exist = var.is_location_exist
  location          = var.location
  managed_from      = var.managed_from
  location_zones    = var.location_zones
  host_labels       = var.host_labels
  ibm_region        = var.ibm_region
  resource_group    = var.resource_group
  host_provider     = "ibm"
}
```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name                                  | Description                                                       | Type     | Default | Required |
|---------------------------------------|-------------------------------------------------------------------|----------|---------|----------|
| ibm_region                            | The location or the region in which VM instance exists.           | string   | n/a     | no       |
| resource_group                        | Resource Group Name that has to be targeted.                      | string   | n/a     | yes      |
| location                              | Name of the Location that has to be created                       | string   | n/a     | yes      |
| is_location_exist                     | Determines if the location has to be created or not               | bool     | false   | yes      |
| managed_from                          | The IBM Cloud region to manage your Satellite location from.      | string   | n/a     | yes      |
| location_zones                        | Allocate your hosts across three zones for Higher availablity     | list     | n/a     | no       |
| host_labels                           | Add labels to attach host script                                  | list     | n/a     | no       |
| location_bucket                       | COS bucket name                                                   | string   | n/a     | no       |
| host_provider                         | The cloud provider of host|vms.                                   | string   | ibm     | no       |

## Outputs

| Name | Description |
|------|-------------|
| location_id | location ID value |
| host_script | Raw content of attach host script |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Note

All optional fields are given value `null` in varaible.tf file. User can configure the same by overwriting with appropriate values.

