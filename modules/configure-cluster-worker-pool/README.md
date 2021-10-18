# This Module is used to create worker pool

This module is used to configure a `worker pool` to an existing ROKS cluster

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
module "satellite-cluster-workerpool" {
  //Uncomment following line to point the source to registry level module
  //source = "terraform-ibm-modules/satellite/ibm//modules/configure-cluster-worker-pool"

  source                    = "../../modules/cluster"
  create_cluster_workerpool = var.create_cluster_worker_pool
  worker_pool_name          = var.worker_pool_name
  cluster                   = var.cluster
  zones                     = var.location_zones
  location                  = var.location
  resource_group            = var.resource_group
  kube_version              = var.kube_version
  worker_count              = var.worker_count
  host_labels               = var.wp_host_labels
  tags                      = var.tags
}
```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name                          | Description                                                       | Type     | Default | Required |
|-------------------------------|-------------------------------------------------------------------|----------|---------|----------|
| resource_group                | Resource Group Name that has to be targeted.                      | string   | n/a     | yes      |
| create_cluster_worker_pool    | Create Cluster worker pool                                        | bool     | false   | no       |
| worker_pool_name              | Worker pool name                                                  | string   | n/a     | yes      |
| cluster                       | Name of the ROKS Cluster that has to be created                   | string   | n/a     | yes      |
| zones                         | Allocate your hosts across these three zones                      | set      | n/a     | yes      |
| kube_version                  | The OpenShift Container Platform version                          | string   | n/a     | no       |
| host_labels                   | List of host labels to assign host to worker pool                 | list     | n/a     | no       |
| workerpool_labels             | Labels on the worker pool                                         | map      | n/a     | no       |

## Outputs

| Name                     | Description                                                  |
|--------------------------|--------------------------------------------------------------|
| worker_pool_id           | Worker pool id                                               |
| worker_pool_worker_count | The number of worker nodes per zone in the worker pool       |
| worker_pool_zones        | zones of this worker_pool                                    |
| worker_pool_host_labels  | worker pool host labels                                      |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->