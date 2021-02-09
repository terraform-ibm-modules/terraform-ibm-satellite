# satellite-aws

Use this terrafrom automation to set up satellite location on IBM cloud with AWS host.

This example cover end-to-end functionality of IBM cloud satellite by creating satellite location on specified zone. 
It will provision 3 aws host and assign it to setup location control plane.


#### Example uses below 3 terraform modules to set up the satellite on AWS:

1. [satellite-location](location.tf) This module `creates satellite location` for the specified zone|location|region and `generates script` named addhost.sh in the working directory.
2. [ec2](instance.tf) This module will provision AWS EC2 instance and use the generated script in module as `user_data` and runs the script. At this stage all the VMs that has run addhost.sh will be attached to the satellite location and will be in unassigned state.
3. [satellite-host](host.tf) This module assigns 3 aws hosts to the location control plane.

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
  source            = "../../modules/location"

  location          = var.location_name
  zone              = var.location_zone
  label             = var.location_label
  ibmcloud_api_key  = var.ibmcloud_api_key
  ibm_region        = var.ibm_region
  endpoint          = "cloud.ibm.com"
  resource_group    = var.resource_group
  host_provider     = "aws"
}

module "ec2" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  
  depends_on                  = [ module.satellite-location ]
  instance_count              = 4
  name                        = "${var.vm_prefix}-host"
  use_num_suffix              = true
  ami                         = data.aws_ami.redhat_linux.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.keypair.key_name
  subnet_id                   = tolist(data.aws_subnet_ids.all.ids)[0]
  vpc_security_group_ids      = [module.security_group.this_security_group_id]
  associate_public_ip_address = true
  placement_group             = aws_placement_group.web.id
  user_data                   = file(replace("${path.module}/addhost.sh*${module.satellite-location.module_id}", "/[*].*/", ""))
 
  tags = {
    "Name"  = "${var.vm_prefix}-host"
  }

}

module "satellite-host" {
  source            = "../../modules/host"
  
  module_depends_on = module.ec2
  host_count        = var.satellite_host_count
  host_vm           = module.ec2.private_dns
  location_name     = var.location_name
  ibmcloud_api_key  = var.ibmcloud_api_key
  ibm_region        = var.ibm_region
  endpoint          = "cloud.ibm.com"
  resource_group    = var.resource_group
  host_provider     = "aws"
}

...
...
```
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name                                  | Description                                                       | Type     | Default | Required |
|---------------------------------------|-------------------------------------------------------------------|----------|---------|----------|
| ibmcloud_api_key                      | IBM Cloud API Key                                                 | string   | n/a     | yes      |
| ibm_region                            | Region of the IBM Cloud account. Currently supported regions for satellite are `us-east` and `eu-gb` region.                                 | string   | us-east | yes      |
| resource_group                        | Resource group name that has to be targeted                       | string   | n/a     | no       |
| aws_access_key                        | AWS access key                                                    | string   | n/a     | yes      |
| aws_secret_key                        | AWS secret key                                                    | string   | n/a     | yes      |
| aws_region                            | AWS cloud region                                                  | string   | us-east-1  | yes   |
| location_name                         | Name of the location that has to be created                       | string   | satellite-aws     | yes |
| location_label                        | Label to create location                                          | string   | env=dev |  yes     |
| satellite_host_count                  | The total number of aws host to create for control plane. satellite_host_count value should always be in multiples of 3, such as 3, 6, 9, or 12 hosts                 | number   | 3 |  yes     |
| addl_host_count                       | The total number of additional aws host                            | number   | 0 |  yes     |
| instance_type                         | The type of aws instance to start, satellite only accepts `m5d.2xlarge` or `m5d.4xlarge` as instance type.                                   | string   | m5d.2xlarge     | yes |
| ssh_public_key                        | SSH Public Key. Get your ssh key by running `ssh-key-gen` command | string   | n/a     | no |
| resource_prefix                       | Name to be used on all aws resources as prefix                        | string   | satellite-aws     | yes |

## Outputs

| Name | Description |
|------|-------------|
| satellite_location | satellite location value |
| module_id | satellite-location module ID |

## Note

* satellite-location module download attach host script in the /tmp/.schematics directory and appends respective permissions to the script.
* The modified attach host script will be used in the `user_data` attribute of EC2 module.
* If your running 'satellite-location' module locally. User has to create '/tmp/.schematics' directory for downloading attach host script. 
