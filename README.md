# IBM Cloud Satellite Module

Use this terrafrom automation to set up satellite location on IBM cloud.
It will provision satellite location and create 6 VSIs and assign 3 host to control plane, and provision ROKS satellite cluster and auto assign 3 host to cluster,
Configure cluster worker pool to an existing ROKS satellite cluster.

This is a collection of sub modules that make it easier to provision a satellite on IBM Cloud.
* location
* host
* cluster
* configure-cluster-worker-pool

## Overview

IBM Cloud® Satellite helps you deploy and run applications consistently across all on-premises, edge computing and public cloud environments from any cloud vendor. It standardizes a core set of Kubernetes, data, AI and security services to be centrally managed as a service by IBM Cloud, with full visibility across all environments through a single pane of glass. The result is greater developer productivity and development velocity.

https://cloud.ibm.com/docs/satellite?topic=satellite-getting-started

## Features

- Create satellite location.
- Create 6 VSIs with RHEL 7.9.
- Assign the 3 hosts to the location control plane.
- *Conditional creation*:
  * Create a Red Hat OpenShift on IBM Cloud cluster and assign the 3 hosts to the cluster, so that you can run OpenShift workloads in your location.
  * Configure a worker pool to an existing OpenShift Cluster.

<table cellspacing="10" border="0">
  <tr>
    <td>
      <img src="images/providers/satellite.png" />
    </td>
  </tr>
</table>


## Compatibility

This module is meant for use with Terraform 0.13 or later.

## Note

* `location` module creates new location or use existing location ID/name. If user pass the location which is already exist,   satellite-location module will error out and exit the module. In such cases user has to set `is_location_exist` value to true. So that module will use existing location for processing.
* All optional fields are given value `null` in varaible.tf file. User can configure the same by overwriting with appropriate values.
* 'satellite-location' module download attach host script in the home directory and appends respective permissions to the script.
* The modified script must be used in the `user_data` attribute of VSI instance
* If we want to make use of a particular version of module, then set the argument "version" to respective module version.

## Requirements

### Terraform plugins

- [Terraform](https://www.terraform.io/downloads.html) 0.13 or later.
- [terraform-provider-ibm](https://github.com/IBM-Cloud/terraform-provider-ibm)

## Install

### Terraform

Be sure you have the correct Terraform version (0.13 or later), you can choose the binary here:
- https://releases.hashicorp.com/terraform/

### Terraform provider plugins

Be sure you have the compiled plugins on $HOME/.terraform.d/plugins/

- [terraform-provider-ibm](https://github.com/IBM-Cloud/terraform-provider-ibm)

## Example Usage
``` hcl
provider "ibm" {
  region  = var.region
}

module "satellite-ibm" {
  source = "github.com/terraform-ibm-modules/terraform-ibm-satellite"

  is_location_exist           = var.is_location_exist
  region                      = var.region
  resource_group              = var.resource_group
  location                    = var.location
  managed_from                = var.managed_from
  location_zones              = var.location_zones
  host_labels                 = var.host_labels
  host_provider               = "ibm"
  create_cluster              = var.create_cluster
  cluster                     = var.cluster
  cluster_host_labels         = var.cluster_host_labels
  create_cluster_worker_pool  = var.create_cluster
  worker_pool_name            = var.worker_pool_name
  worker_pool_host_labels     = var.cluster_host_labels
  create_timeout              = var.create_timeout
  update_timeout              = var.update_timeout
  delete_timeout              = var.delete_timeout
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name                                  | Description                                                       | Type     | Default | Required |
|---------------------------------------|-------------------------------------------------------------------|----------|---------|----------|
| resource_group                        | Resource Group Name that has to be targeted.                      | string   | n/a     | yes      |
| region                                | The location or the region in which VM instance exists.           | string   | us-east | no       |
| location                              | Name of the Location that has to be created                       | string   | n/a     | satellite-ibm  |
| is_location_exist                     | Determines if the location has to be created or not               | bool     | false   | no       |
| managed_from                          | The IBM Cloud region to manage your Satellite location from.      | string   | wdc     | yes      |
| location_zones                        | Allocate your hosts across three zones for higher availablity     | list     | ["us-east-1", "us-east-2", "us-east-3"]     | no  |
| host_labels                           | Add labels to attach host script                                  | list     | [env:prod]  | no   |
| location_bucket                       | COS bucket name                                                   | string   | n/a     | no       |
| host_count                            | The total number of host to create for control plane. host_count value should always be in multiples of 3, such as 3, 6, 9, or 12 hosts | number | 3 |  yes |
| addl_host_count                       | The total number of additional host                               | number   | 3       | no       |
| host_provider                         | The cloud provider of host/vms.                                   | string   | ibm     | no       |
| is_prefix                             | Prefix to the Names of all VSI Resources                          | string   | satellite-ibm | yes|
| public_key                            | Public SSH key used to provision Host/VSI                         | string   | n/a     | no       |
| location_profile                      | Profile information of location hosts                             | string   | mx2-8x64| no       |
| cluster_profile                       | Profile information of cluster hosts                              | string   | mx2-8x64| no       |
| create_cluster                        | Create cluster:Disable this, not to provision cluster             | bool     | true    | no       |
| cluster                               | Name of the ROKS Cluster that has to be created                   | string   | n/a     | yes      |
| cluster_zones                         | Allocate your hosts across these three zones                      | set      | n/a     | yes      |
| kube_version                          | Kuber version                                                     | string   | 4.7_openshift | no |
| default_wp_labels                     | Labels on the default worker pool                                 | map      | n/a     | no       |
| workerpool_labels                     | Labels on the worker pool                                         | map      | n/a     | no       |
| cluster_tags                          | List of tags for the cluster resource                             | list     | n/a     | no       |
| create_cluster_worker_pool            | Create Cluster worker pool                                        | bool     | false   | no       |
| worker_pool_name                      | Worker pool name                                                  | string   | satellite-worker-pool  | no |
| workerpool_labels                     | Labels on the worker pool                                         | map      | n/a     | no       |
| create_timeout                        | Timeout duration for creation                                     | string   | n/a     | no       |
| update_timeout                        | Timeout duration for updation                                     | string   | n/a     | no       |
| delete_timeout                        | Timeout duration for deletion                                     | string   | n/a     | no       |


## Outputs

| Name                     | Description                      |
|--------------------------|----------------------------------|
| location_id              | Location id                      |
| host_script              | Host registartion script content |
| host_ids                 | Assigned host id's               |
| floating_ip_ids          | Floating IP id's                 |
| floating_ip_addresses    | Floating IP Addresses            |
| vpc                      | VPC id                           |
| default_security_group   | Security group name              |
| subnets                  | Subnets id's                     |
| cluster_id               | Cluster id                       |
| cluster_worker_pool_id   | Cluster worker pool id           |
| worker_pool_worker_count | worker count                     |
| worker_pool_zones        | workerpool zones                 |



## Pre-commit Hooks

Run the following command to execute the pre-commit hooks defined in `.pre-commit-config.yaml` file

  `pre-commit run -a`

We can install pre-coomit tool using

  `pip install pre-commit`

## How to input varaible values through a file

To review the plan for the configuration defined (no resources actually provisioned)

`terraform plan -var-file=./input.tfvars`

To execute and start building the configuration defined in the plan (provisions resources)

`terraform apply -var-file=./input.tfvars`

To destroy the VPC and all related resources

`terraform destroy -var-file=./input.tfvars`

All optional parameters by default will be set to null in respective example's varaible.tf file. If user wants to configure any optional paramter he has overwrite the default value.