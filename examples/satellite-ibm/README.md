# satellite-ibm

Use this terraform automation to set up IBM Cloud satellite location for Virtual Server Instances of IBM VPC Infrastructure.

This example uses two modules to set up the control plane.

1. [location.](../modules/location) This module `creates satellite location` for the specified zone|location|region and `generates script` named addhost.sh in the working directory by performing attach host.The generated script is used by `ibm_is_instance` as `user_data` and runs the script. At this stage all the VMs that has run addhost.sh will be attached to the satellite location and will be in unassigned state.
2. [host](../modules/host) This module assigns hosts to the location.
 
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
module "satellite_location" {
  source            = "../../modules/location"
  zone              = var.location_zone
  location          = var.location_name
  label             = var.labels
  host_provider     = "ibm"
  ibmcloud_api_key  = var.ibmcloud_api_key
  region            = var.region
  resource_group    = var.resource_group
  endpoint          = "cloud.ibm.com"
}
module "satellite_host" {
  source            = "../../modules/host"
  module_depends_on = ibm_is_instance.satellite_instance
  ip_count          = 3
  host_vm           = ibm_is_instance.satellite_instance[*].name
  location          = var.location_name
  ibmcloud_api_key  = var.ibmcloud_api_key
  region            = var.region
  endpoint          = "cloud.ibm.com"
  host_provider     = "ibm"
  resource_group    = var.resource_group
}
```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name                                  | Description                                                       | Type     | Default | Required |
|---------------------------------------|-------------------------------------------------------------------|----------|---------|----------|
| resource_group                        | Resource Group Name that has to be targeted.                      | string   | n/a     | yes      |
| ibmcloud_api_key                      | IBM Cloud API Key.                                                | string   | n/a     | yes      |
| region                                | The location or the region in which VM instance exists.           | string   | n/a     | yes      |
| endpoint                              | Endpoint of production environment of IBM Cloud                   | string   |cloud.ibm.com| yes  |
| location_name                         | Name of teh Location that has to be created                       | string   | n/a     | yes      |
| location_zone                         | Zone in which satellite location has to be created. Ex:wdc06      | string   | n/a     | yes      |
| labels                                | Label to create location                                          | string   |prod=true| yes      |
| is_prefix                             | Prefix to the Names of all VSI Resources                          | string   | n/a     | yes      |
| public_key                            | Public SSH key used to provision Host/VSI                         | string   | n/a     | yes      |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Note

* All optional fields are given value `null` in varaible.tf file. User can configure the same by overwriting with appropriate values.

* Satellite Location module download attach host script in the current directory and * appends respective permissions to the script..The modified script must be used in the `user_data` attribute of VSI instance

