# This Module is used to create satellite cluster

This module depends on `satellite-host` module.
 
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
## Example Usage
``` hcl

module "satellite-cluster" {
  source                = "../../modules/cluster"
 
  module_depends_on     = module.satellite-host
  location_name         = var.location_name
  cluster_name          = var.cluster_name
  ibmcloud_api_key      = var.ibmcloud_api_key
  ibm_region            = var.ibm_region
  endpoint              = "cloud.ibm.com"
  resource_group        = var.resource_group
}
```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
