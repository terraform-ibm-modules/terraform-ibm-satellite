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

  host_count        = var.host_count
  location          = module.satellite-location.location_id
  host_vms          = ibm_is_instance.satellite_instance[*].name
  location_zones    = var.location_zones
  host_labels       = var.host_labels
  host_provider     = "ibm"
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name                                  | Description                                                       | Type     | Default | Required |
|---------------------------------------|-------------------------------------------------------------------|----------|---------|----------|
| ibmcloud_api_key                      | IBM Cloud API Key.                                                | string   | n/a     | yes      |
| resource_group                        | Resource Group Name that has to be targeted.                      | string   | n/a     | yes      |
| ibm_region                            | The location or the region in which VM instance exists.           | string   | n/a     | yes      |
| endpoint                              | Endpoint of production environment of IBM Cloud                   | string   |cloud.ibm.com| no  |
| location                              | Name of the Location                                              | string   | n/a     | yes      |
| host_vms                              | List of host names to assign to satellite control plane           | list     | n/a     | yes      |
| location_zones                        | List of high availablity zones for host                           | list     | n/a     | no       |
| host_labels                           | Host labels to assign host to control plane                       | list     | n/a     | no       |
| host_provider                         | The cloud provider of host/vms.                                   | string   | ibm     | no       |


<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Note

All optional fields are given value `null` in varaible.tf file. User can configure the same by overwriting with appropriate values.

