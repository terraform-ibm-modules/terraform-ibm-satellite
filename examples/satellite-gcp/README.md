# satellite-google

Use this terrafrom automation to set up satellite location on IBM cloud with Google host.

This example cover end-to-end functionality of IBM cloud satellite by creating satellite location on specified zone.
It will provision Google host and assign it to setup location control plane.


#### Example uses below 3 terraform modules to set up the satellite on Google:

1. [satellite-location](main.tf) This module `creates satellite location` for the specified zone|location|region and `generates script` named addhost.sh in the home directory.
2. [Compute VM Instances](instance.tf) This resouurce will provision Google Compute virtual machine instances, uses the generated script in module as `metadata.startup-script` and runs the script. At this stage all the VMs that has run addhost.sh will be attached to the satellite location and will be in unassigned state.
3. [satellite-host](host.tf) This module assigns Google hosts to the location control plane.

## Compatibility

This module is meant for use with Terraform 0.13 or later.

## Requirements

### Terraform plugins

- [Terraform](https://www.terraform.io/downloads.html) 0.13 or later.
- [terraform-provider-ibm](https://github.com/IBM-Cloud/terraform-provider-ibm)
- [terraform-provider-google](https://github.com/hashicorp/terraform-provider-google)
- To authenticate google provider please refer [docs](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference)

## Install

### Terraform

Be sure you have the correct Terraform version ( 0.13 or later), you can choose the binary here:
- https://releases.hashicorp.com/terraform/

### Terraform provider plugins

Be sure you have the terraform block with required providers in versions.tf file..

```terraform
terraform {
  required_version = ">=0.13"
  required_providers {
    ibm = {
      source = "ibm-cloud/ibm"
      version= "<specific version>" // Latest version will be considered if there is no version mentioned
    }
  }
}
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
  resource_group    = var.ibm_resource_group
  host_provider     = "google"
}

module "gcp_host-template" {
  source     = "terraform-google-modules/vm/google//modules/instance_template"
  version    = "6.5.0"
  project_id = var.gcp_project
  # network     = module.gcp_network.network_name
  subnetwork         = local.subnet_ids[0]
  subnetwork_project = var.gcp_project
  name_prefix        = "${var.gcp_resource_prefix}-template"
  tags               = ["ibm-satellite", var.gcp_resource_prefix]
  labels = {
    ibm-satellite = var.gcp_resource_prefix
  }
  metadata = {
    ssh-keys       = var.ssh_public_key != null ? "${var.gcp_ssh_user}:${var.ssh_public_key}" : tls_private_key.rsa_key.0.public_key_openssh
    startup-script = module.satellite-location.host_script
  }
  # startup_script=module.satellite-location.host_script
  machine_type         = var.instance_type
  can_ip_forward       = false
  source_image_project = "rhel-cloud"
  source_image         = "rhel-7-v20201112"
  source_image_family  = "rhel-7"
  disk_size_gb         = 100
  disk_type            = "pd-standard"
  disk_labels = {
    ibm-satellite = var.gcp_resource_prefix
  }
  auto_delete     = true
  service_account = { email = "", scopes = [] }
}
data "google_compute_zones" "available" {
  project = var.gcp_project
  region  = var.gcp_region
}
resource "google_compute_instance_from_template" "gcp_hosts" {
  count   = var.satellite_host_count + var.addl_host_count
  name    = "${var.gcp_resource_prefix}-host-${count.index}"
  project = var.gcp_project
  zone    = data.google_compute_zones.available.names[count.index % length(data.google_compute_zones.available.names)]
  network_interface {
    network            = module.gcp_network.network_name
    subnetwork         = element(local.subnet_ids, count.index)
    subnetwork_project = var.gcp_project
  }
  source_instance_template = module.gcp_host-template.self_link
}

module "satellite-host" {
  depends_on     = [google_compute_instance_from_template.gcp_hosts]
  source         = "../../modules/host"
  host_count     = var.satellite_host_count
  location       = module.satellite-location.location_id
  host_vms       = google_compute_instance_from_template.gcp_hosts.*.name
  location_zones = var.location_zones
  host_labels    = var.host_labels
  host_provider  = "google"
}
```

## Note

* `satellite-location` module creates new location or use existing location ID/name to process. If user pass the location which is already exist,   satellite-location module will error out and exit the module. In such cases user has to set `is_location_exist` value to true. So that module will use existing location for processing.
* `satellite-location` module download attach host script to the $HOME directory and appends respective permissions to the script.
* `satellite-location` module will update the attach host script and will be used in the `metadata.startup-script` attribute of `gcp_host-template` module.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name                                  | Description                                                       | Type     | Default | Required |
|---------------------------------------|-------------------------------------------------------------------|----------|---------|----------|
| ibmcloud_api_key                      | IBM Cloud API Key                                                 | string   | n/a     | yes      |
| ibm_resource_group                    | IBM Resource group name that has to be targeted                   | string   | `default`     | yes       |
| gcp_credentials                           | Google Credentials | string  | n/a  | yes   |
| gcp_project                           | Google Project Id                                         | string  | n/a  | yes   |
| gcp_region                             | Google Region                                                      | string   | `us-east1`  | yes   |
| location                              | Name of the Location that has to be created                       | string   | satellite-google | yes   |
| is_location_exist                     | Determines if the location has to be created or not               | bool     | false   | yes      |
| managed_from                          | The IBM Cloud region to manage your Satellite location from.      | string   | wdc   | yes      |
| location_zones                        | Allocate your hosts across three zones for higher availablity     | list     | ["us-east-1", "us-east-2", "us-east-3"]    | yes      |
| host_labels                                | Add labels to attach host script                                  | list     | [env:prod]  | no   |
| location_bucket                       | COS bucket name                                                   | string   | n/a     | no       |
| gcp_resource_prefix                       | Name to be used on all google resources as prefix                        | string   | satellite-google     | yes |
| satellite_host_count                  | [Deprecated] The total number of google host to create for control plane. satellite_host_count value should always be in multiples of 3, such as 3, 6, 9, or 12 hosts                 | number   | null |  no     |
| addl_host_count                       | [Deprecated] The total number of additional google host            | number   | null             | no    |
| instance_type                         | [Deprecated] The type of google instance to start                  | string   | null             | no    |
| cp_hosts                              | A list of GCP host objects used to create the location control plane, including parameters instance_type and count. Control plane count values should always be in multipes of 3, such as 3, 6, 9, or 12 hosts.                  | list   | [<br>&ensp; {<br>&ensp;&ensp; instance_type = "n2-standard-4"<br>&ensp; count         = 3<br>&ensp;&ensp; }<br>]             | yes    |
| addl_hosts                            | A list of GCP host objects used for provisioning services on your location after setup, including instance_type and count, see cp_hosts for an example.                  | list   | []             | yes    |
| worker_image_family                          | Specify the image family for hosts to be created with                    | string   | rhel-7    | no       |
| worker_image_project                          | Specify the image project for hosts to be created with                    | string   | rhel-cloud    | no       |
| ssh_public_key                        | SSH Public Key. Get your ssh key by running `ssh-key-gen` command | string   | n/a     | no |
| gcp_ssh_user                        | "SSH User of above provided ssh_public_key" | string   | n/a     | no |



## Outputs

| Name | Description |
|------|-------------|
| location_id | location ID value |
| gcp_host_names | Names of Google Hosts |
| gcp_host_links | Self Links of Google Hosts |