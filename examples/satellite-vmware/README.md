# satellite-vmware

**Note: this is currently under development, and not yet fully tested.**

Use this terrafrom automation to set up a Satellite location on IBM Cloud with hosts in VMware Cloud Director.

This example will:
- Create the IBM Cloud Satellite location
- Create RHCOS VMs in VMware Cloud Director with 3 different specifications: control plane, worker, and storage
- Attach the VMs to the Satellite location
- Assign the control plane VMs to the Satellite location control plane


## Compatibility

This module is meant for use with Terraform 1.1 or later.

## Requirements

### Terraform plugins

- [Terraform](https://www.terraform.io/downloads.html) 1.1 or later.
- [terraform-provider-ibm](https://github.com/IBM-Cloud/terraform-provider-ibm)

## Install

### Terraform provider plugins

Be sure you have the compiled plugins on $HOME/.terraform.d/plugins/

- [terraform-provider-ibm](https://github.com/IBM-Cloud/terraform-provider-ibm)


## Note

* `satellite-location` module creates a new location or uses an existing location ID/name to process. If using an existing location, set `is_location_exist` to `true`.
* `satellite-location` module download attach host script to the $HOME directory and appends respective permissions to the script.
* `satellite-location` module will update the attach host script pass the ignition data to VMware during VM creation


## Inputs

| Name                                  | Description                                                       | Type     | Default | Required |
|---------------------------------------|-------------------------------------------------------------------|----------|---------|----------|
<!-- | ibmcloud_api_key                      | IBM Cloud API Key                                                 | string   | n/a     | yes      |
| resource_group                        | Resource group name that has to be targeted                       | string   | n/a     | no       |
| aws_access_key                        | AWS access key                                                    | string   | n/a     | yes      |
| aws_secret_key                        | AWS secret key                                                    | string   | n/a     | yes      |
| aws_region                            | AWS cloud region                                                  | string   | us-east-1  | yes   |
| location                              | Name of the Location that has to be created                       | string   | satellite-aws  | yes   |
| is_location_exist                     | Determines if the location has to be created or not               | bool     | false   | yes      |
| managed_from                          | The IBM Cloud region to manage your Satellite location from.      | string   | wdc     | yes      |
| location_zones                        | Allocate your hosts across three zones for higher availablity     | list     | []      | no       |
| labels                                | Add labels to attach host script                                  | list     | [env:prod]  | no   |
| location_bucket                       | COS bucket name                                                   | string   | n/a     | no       |
| host_provider                         | The cloud provider of host/vms.                                   | string   | aws     | no       |
| satellite_host_count                  | [Deprecated] The total number of aws host to create for control plane. satellite_host_count value should always be in multiples of 3, such as 3, 6, 9, or 12 hosts   | number   | 3 |  yes     |
| addl_host_count                       | [Deprecated] The total number of additional aws host                            | number   | 0 |  yes     |
| instance_type                         | [Deprecated] The type of aws instance to create.     | string   | m5d.xlarge     | yes |
| cp_hosts                              | A list of AWS host objects used to create the location control plane, including parameters instance_type and count. Control plane count values should always be in multipes of 3, such as 3, 6, 9, or 12 hosts.                  | list   | [<br>&ensp; {<br>&ensp;&ensp; instance_type = "m5d.xlarge"<br>&ensp; count         = 3<br>&ensp;&ensp; }<br>]             | yes    |
| addl_hosts                            | A list of AWS host objects used for provisioning services on your location after setup, including instance_type and count, see cp_hosts for an example.                  | list   | []             | yes    |
| ssh_public_key                        | SSH Public Key. Get your ssh key by running `ssh-key-gen` command | string   | n/a     | no |
| resource_prefix                       | Name to be used on all aws resources as prefix                        | string   | satellite-aws     | yes | -->
