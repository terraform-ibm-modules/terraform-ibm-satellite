# This Module is used to create satellite ROKS Cluster

This module creates `satellite cluster and worker pool` for the specified location.

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
module "satellite-cluster" {
  //Uncomment following line to point the source to registry level module
  //source = "terraform-ibm-modules/satellite/ibm//modules/cluster"

  source               = "./modules/cluster"
  create_cluster       = var.create_cluster
  cluster              = var.cluster
  location             = module.satellite-host.location
  kube_version         = var.kube_version
  default_wp_labels    = var.default_wp_labels
  zones                = var.cluster_zones
  resource_group       = var.resource_group
  worker_pool_name     = var.worker_pool_name
  worker_count         = var.worker_count
  workerpool_labels    = var.workerpool_labels
  cluster_tags         = var.cluster_tags
  host_labels          = var.cluster_host_labels
}
```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name                          | Description                                                       | Type     | Default | Required |
|-------------------------------|-------------------------------------------------------------------|----------|---------|----------|
| resource_group                | Resource Group Name that has to be targeted.                      | string   | n/a     | no       |
| ibm_region                    | The location or the region in which VM instance exists.           | string   | us-east | yes      |
| create_cluster                | Create cluster                                                    | bool     | true    | no       |
| cluster                       | Name of the ROKS Cluster that has to be created                   | string   | n/a     | yes      |
| cluster_zones                 | Allocate your hosts across these three zones                      | set      | n/a     | yes      |
| kube_version                  | Kuber version                                                     | string   | 4.7_openshift| no |
| cluster_host_labels           | List of host labels to assign host to cluter                      | list     | n/a     | no       |
| default_wp_labels             | Labels on the default worker pool                                 | map      | n/a     | no       |
| cluster_tags                  | List of tags for the cluster resource                             | list     | n/a     | no       |

## Outputs

| Name                     | Description                   |
|--------------------------|-------------------------------|
| cluster_id               | Cluster id                    |
| cluster_crn              | Cluster crn                   |
| server_url               | Cluster server URL            |
| cluster_state            | Cluster state                 |
| cluster_status           | Cluster status                |
| ingress_hostname         | The Ingress hostname          |
| ingress_secret           | The Ingress secret            |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->