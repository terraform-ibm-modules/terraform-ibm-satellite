# satellite-ibm

Use this terraform automation to set up IBM Cloud satellite location for Virtual Server Instances of IBM VPC Infrastructure.

This example uses two modules to set up the control plane.

1. [satellite-location](main.tf) This module creates `satellite location` for the specified zone|location|region and `generates script` named addhost.sh in the home directory by performing attach host.The generated script is used by `ibm_is_instance` as `user_data` and runs the script. At this stage all the VMs that has run addhost.sh will be attached to the satellite location and will be in unassigned state.
2. [satellite-host](host.tf) This module assigns 3 host to setup the location control plane.

 
## Prerequisite

* Set up the IBM Cloud command line interface (CLI), the Satellite plug-in, and other related CLIs.
* Install cli and plugin package
```console
    ibmcloud plugin install container-service
```
* Follow the Host [requirements](https://cloud.ibm.com/docs/satellite?topic=satellite-host-reqs) 
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
  source            = "../../modules/location"

  is_location_exist   = var.is_location_exist
  location            = var.location
  managed_from        = var.managed_from
  location_zones      = var.location_zones
  host_labels         = var.host_labels
  ibmcloud_api_key    = var.ibmcloud_api_key
  ibm_region          = var.ibm_region
  resource_group      = var.resource_group 
  host_provider       = "ibm"
}

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

## Note

* `satellite-location` module creates new location or use existing location ID/name. If user pass the location which is already exist,   satellite-location module will error out and exit the module. In such cases user has to set `is_location_exist` value to true. So that module will use existing location for processing.
* All optional fields are given value `null` in varaible.tf file. User can configure the same by overwriting with appropriate values.
* 'satellite-location' module download attach host script in the home directory and appends respective permissions to the script.
* The modified script must be used in the `user_data` attribute of VSI instance.


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name                                  | Description                                                       | Type     | Default | Required |
|---------------------------------------|-------------------------------------------------------------------|----------|---------|----------|
| ibmcloud_api_key                      | IBM Cloud API Key.                                                | string   | n/a     | yes      |
| resource_group                        | Resource Group Name that has to be targeted.                      | string   | n/a     | no       |
| ibm_region                            | The location or the region in which VM instance exists.           | string   | us-east | yes      |
| location                              | Name of the Location that has to be created                       | string   | n/a     | yes      |
| is_location_exist                     | Determines if the location has to be created or not               | bool     | false   | yes      |
| managed_from                          | The IBM Cloud region to manage your Satellite location from.      | string   | wdc04   | yes      |
| location_zones                        | Allocate your hosts across three zones for higher availablity     | list     | n/a     | no       | 
| host_labels                           | Add labels to attach host script                                  | list     | [env:prod]  | no   |
| location_bucket                       | COS bucket name                                                   | string   | n/a     | no       |
| host_count                            | The total number of host to create for control plane. host_count value should always be in multiples of 3, such as 3, 6, 9, or 12 hosts                 | number   | 3 |  yes     |
| addl_host_count                       | The total number of additional host                               | number   | 0       |  yes     |
| host_provider                         | The cloud provider of host/vms.                                   | string   | ibm     | no       |
| is_prefix                             | Prefix to the Names of all VSI Resources                          | string   | n/a     | yes      |
| public_key                            | Public SSH key used to provision Host/VSI                         | string   | n/a     | no       |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->