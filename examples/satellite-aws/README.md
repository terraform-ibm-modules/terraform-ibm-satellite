# satellite-aws

Use this terrafrom automation to set up satellite location on IBM cloud with AWS host.

This example cover end-to-end functionality of IBM cloud satellite by creating satellite location on specified zone.
It will provision AWS host and assign it to setup location control plane.


#### Example uses below 3 terraform modules to set up the satellite on AWS:

1. [satellite-location](main.tf) This module `creates satellite location` for the specified zone|location|region and `generates script` named addhost.sh in the home directory.
2. [ec2](instance.tf) This module will provision AWS EC2 instance and use the generated script in module as `user_data` and runs the script. At this stage all the VMs that has run addhost.sh will be attached to the satellite location and will be in unassigned state.
3. [satellite-host](host.tf) This module assigns AWS hosts to the location control plane.

## Compatibility

This module is meant for use with Terraform 0.13 or later.

## Requirements

### Terraform plugins

- [Terraform](https://www.terraform.io/downloads.html) 0.13 or later.
- [terraform-provider-ibm](https://github.com/IBM-Cloud/terraform-provider-ibm)

## Install

### IBM Cloud CLI

Be sure you have installed IBM Cloud plug-in for Satellite
- https://cloud.ibm.com/docs/satellite?topic=satellite-setup-cli

### Terraform

Be sure you have the correct Terraform version ( 0.13 or later), you can choose the binary here:
- https://releases.hashicorp.com/terraform/

### Terraform provider plugins

Be sure you have the compiled plugins on $HOME/.terraform.d/plugins/

- [terraform-provider-ibm](https://github.com/IBM-Cloud/terraform-provider-ibm)
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
  location_zones    = local.azs
  location_bucket   = var.location_bucket
  host_labels       = var.host_labels
  resource_group    = var.resource_group
  host_provider     = "aws"
}

module "ec2" {
  source                      = "terraform-aws-modules/ec2-instance/aws"

  depends_on                  = [ module.satellite-location ]
  instance_count              = var.satellite_host_count + var.addl_host_count
  name                        = "${var.resource_prefix}-host"
  use_num_suffix              = true
  ami                         = data.aws_ami.redhat_linux.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.keypair.key_name
  subnet_ids                  = module.vpc.public_subnets
  vpc_security_group_ids      = [module.security_group.this_security_group_id]
  associate_public_ip_address = true
  placement_group             = aws_placement_group.satellite-group.id
  user_data                   = data.ibm_satellite_attach_host_script.script.host_script

  tags = {
    ibm-satellite = var.resource_prefix
  }

}

module "satellite-host" {
  //Uncomment following line to point the source to registry level module
  //source = "terraform-ibm-modules/satellite/ibm//modules/host"

  source         = "../../modules/host"
  host_count     = var.satellite_host_count
  location       = module.satellite-location.location_id
  host_vms       = module.ec2.private_dns
  location_zones = length(var.location_zones) == 0 ? local.azs : var.location_zones
  host_labels    = var.host_labels
  host_provider  = "aws"
}
...
```

## Note

* `satellite-location` module creates new location or use existing location ID/name to process. If user pass the location which is already exist,   satellite-location module will error out and exit the module. In such cases user has to set `is_location_exist` value to true. So that module will use existing location for processing.
* `satellite-location` module download attach host script to the $HOME directory and appends respective permissions to the script.
* `satellite-location` module will update the attach host script and will be used in the `user_data` attribute of EC2 module.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name                                  | Description                                                       | Type     | Default | Required |
|---------------------------------------|-------------------------------------------------------------------|----------|---------|----------|
| ibmcloud_api_key                      | IBM Cloud API Key                                                 | string   | n/a     | yes      |
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
| satellite_host_count                  | The total number of aws host to create for control plane. satellite_host_count value should always be in multiples of 3, such as 3, 6, 9, or 12 hosts   | number   | 3 |  yes     |
| addl_host_count                       | The total number of additional aws host                            | number   | 0 |  yes     |
| instance_type                         | The type of aws instance to start, satellite only accepts `m5d.2xlarge` or `m5d.4xlarge` as instance type.     | string   | m5d.2xlarge     | yes |
| ssh_public_key                        | SSH Public Key. Get your ssh key by running `ssh-key-gen` command | string   | n/a     | no |
| resource_prefix                       | Name to be used on all aws resources as prefix                        | string   | satellite-aws     | yes |

## Outputs

| Name | Description |
|------|-------------|
| location_id | location ID value |
| host_script | Raw content of attach host script |