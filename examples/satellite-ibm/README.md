# satellite-ibm

Use this terraform automation to set up IBM Cloud satellite location for Virtual Server Instances of IBM VPC Infrastructure.

This example uses two modules to set up the control plane.

1. [satellite-location](main.tf) This module creates `satellite location` for the specified zone|location|region and `generates script` named addhost.sh in the home directory by performing attach host.The generated script is used by `ibm_is_instance` as `user_data` and runs the script. At this stage all the VMs that has run addhost.sh will be attached to the satellite location and will be in unassigned state.
2. [satellite-host](host.tf) This module assigns 3 host to setup the location control plane.
3. [satellite-cluster](cluster.tf) This module is used to to provision an ROKS cluster on IBM Cloud Infrastructure.
4. [satellite-cluster-worker-pool](cluster.tf) This module is used to configure a worker pool to an existing ROKS cluster.

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
  //Uncomment following line to point the source to registry level module
  //source = "terraform-ibm-modules/satellite/ibm//modules/location"

  source            = "../../modules/location"
  is_location_exist = var.is_location_exist
  location          = var.location
  managed_from      = var.managed_from
  location_zones    = var.location_zones
  location_bucket   = var.location_bucket
  host_labels       = var.host_labels
  ibm_region        = var.ibm_region
  resource_group    = var.resource_group
  host_provider     = "ibm"
}

module "satellite-host" {
  //Uncomment following line to point the source to registry level module
  //source = "terraform-ibm-modules/satellite/ibm//modules/host"

  source         = "../../modules/host"
  host_count     = var.host_count
  location       = module.satellite-location.location_id
  host_vms       = ibm_is_instance.satellite_instance[*].name
  location_zones = var.location_zones
  host_labels    = var.host_labels
  host_provider  = "ibm"
}

module "satellite-cluster" {
  //Uncomment following line to point the source to registry level module
  //source = "terraform-ibm-modules/satellite/ibm//modules/cluster"

  source                     = "../../modules/cluster"
  create_cluster             = var.create_cluster
  cluster                    = var.cluster
  zones                      = var.location_zones
  location                   = var.location
  resource_group             = var.resource_group
  kube_version               = var.kube_version
  worker_count               = var.worker_count
  host_labels                = var.host_labels
  tags                       = var.tags
  default_worker_pool_labels = var.default_worker_pool_labels
  create_timeout             = var.create_timeout
  update_timeout             = var.update_timeout
  delete_timeout             = var.delete_timeout
}

module "satellite-cluster-worker-pool" {
  //Uncomment following line to point the source to registry level module
  //source = "terraform-ibm-modules/satellite/ibm//modules/configure-cluster-worker-pool"

  source                     = "../../modules/configure-cluster-worker-pool"
  create_cluster_worker_pool = var.create_cluster_worker_pool
  worker_pool_name           = var.worker_pool_name
  cluster                    = var.cluster
  zones                      = var.location_zones
  resource_group             = var.resource_group
  kube_version               = var.kube_version
  worker_count               = var.worker_count
  host_labels                = var.worker_pool_host_labels
  tags                       = var.tags
  create_timeout             = var.create_timeout
  delete_timeout             = var.delete_timeout
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
| resource_group                        | Resource Group Name that has to be targeted.                      | string   | n/a     | yes      |
| ibm_region                            | The location or the region in which VM instance exists.           | string   | us-east | no       |
| location                              | Name of the Location that has to be created                       | string   | n/a     | satellite-ibm|
| is_location_exist                     | Determines if the location has to be created or not               | bool     | false   | no       |
| managed_from                          | The IBM Cloud region to manage your Satellite location from.      | string   | wdc     | no       |
| location_zones                        | Allocate your hosts across three zones for higher availablity     | list     | ["us-east-1", "us-east-2", "us-east-3"]     | no  |
| host_labels                           | Add labels to attach host script                                  | list     | [env:prod]  | no   |
| location_bucket                       | COS bucket name                                                   | string   | n/a     | no       |
| host_count                            | [Deprecated] The total number of host to create for control plane. host_count value should always be in multiples of 3, such as 3, 6, 9, or 12 hosts | number | 3 | no |
| addl_host_count                       | [Deprecated] The total number of additional host                               | number   | 3       | no       |
| host_provider                         | The cloud provider of host/vms.                                   | string   | ibm     | no       |
| is_prefix                             | Prefix to the Names of all VSI Resources                          | string   | satellite-ibm | yes|
| public_key                            | Public SSH key used to provision Host/VSI                         | string   | n/a     | no       |
| location_profile                      | [Deprecated] Profile information of location hosts                             | string   | mx2-8x64| no       |
| cluster_profile                       | [Deprecated] Profile information of cluster hosts                              | string   | mx2-8x64| no       |
| cp_hosts                              | A list of IBM host objects used to create the location control plane, including parameters instance_type and count. Control plane count values should always be in multipes of 3, such as 3, 6, 9, or 12 hosts.                  | list   | [<br>&ensp; {<br>&ensp;&ensp; instance_type = "mx2-8x64"<br>&ensp; count         = 3<br>&ensp;&ensp; }<br>]             | no    |
| addl_hosts                            | A list of IBM host objects used for provisioning services on your location after setup, including instance_type and count, see cp_hosts for an example.                  | list   | []             | no    |
| create_cluster                        | Create cluster Disable this, not to provision cluster             | bool     | true    | no       |
| cluster                               | Name of the ROKS Cluster that has to be created                   | string   | satellite-ibm-cluster     | no      |
| cluster_zones                         | Allocate your hosts across these three zones                      | set      | n/a     | no      |
| kube_version                          | Kuber version                                                     | string   | 4.7_openshift | no |
| default_wp_labels                     | Labels on the default worker pool                                 | map      | n/a     | no       |
| workerpool_labels                     | Labels on the worker pool                                         | map      | n/a     | no       |
| cluster_tags                          | List of tags for the cluster resource                             | list     | n/a     | no       |
| create_cluster_worker_pool            | Create Cluster worker pool                                        | bool     | false   | no       |
| worker_pool_name                      | Worker pool name                                                  | string   | satellite-worker-pool     | no       |
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


<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->