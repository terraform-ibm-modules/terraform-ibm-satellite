# satellite-aws

Use this to set up satellite on AWS with EC2 Instances, using Terraform.

This example uses three terraform modules to set up the control plane.

1. [satellite_location.](../modules/location) This module `creates satellite location` for the specified zone|location|region and `generates script` named addhost.sh in the working directory.
2. [ec2](instance.tf) This module will provision AWS EC2 instance and use the generated script in module as `user_data` and runs the script. At this stage all the VMs that has run addhost.sh will be attached to the satellite location and will be in unassigned state.
3. [satellite-host](../modules/host) This module assigns hosts to the location control plane.

## Prerequisite

* Install Terraform 0.13
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
## Example Usage
``` hcl
module "satellite-location" {
  source            = "../../modules/location"
  zone              = var.zone
  location          = var.location
  label             = var.label
  ibmcloud_api_key  = var.ibmcloud_api_key
  region            = var.region
  endpoint          = var.endpoint
  resource_group    = var.resource_group
  host_provider     = "aws"
}

module "ec2" {
  source = "terraform-aws-modules/ec2-instance/aws"
  
  depends_on                  = [module.satellite-location, data.local_file.satellite_script ]
  instance_count              = var.instance_count
  name                        = var.vm_prefix
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.keypair.key_name
  subnet_id                   = tolist(data.aws_subnet_ids.all.ids)[0]
  vpc_security_group_ids      = [module.security_group.this_security_group_id]
  associate_public_ip_address = true
  placement_group             = aws_placement_group.web.id
  user_data                   = file(data.local_file.satellite_script.filename)

  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = var.volume_size
    },
  ]

  tags = var.tags

}

module "satellite-host" {
  source            = "../../modules/host"
  module_depends_on = module.ec2
  ip_count          = var.assign_host_count
  host_vm           = module.ec2.private_dns
  location          = var.location
  host_zone         = var.host_zone
  ibmcloud_api_key  = var.ibmcloud_api_key
  region            = var.region
  endpoint          = var.endpoint
  resource_group    = var.resource_group
  host_provider     = "aws"
}
```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name                                  | Description                                                       | Type     | Default | Required |
|---------------------------------------|-------------------------------------------------------------------|----------|---------|----------|
| location_name                         | Name of the Location that has to be created                       | string   | n/a     | yes      |
| location_zone                         | Zone in which satellite location has to be created. Ex:wdc06      | string   | wdc06    | yes      |
| labels                                | Label to create location                                          | string   | env=dev |  yes     |
| ibmcloud_api_key                      | IBM Cloud API Key                                                 | string   | n/a     | yes      |
| endpoint                              | Endpoint of production environment of IBM Cloud                   | string   | cloud.ibm.com     | yes      |
| aws_region                            | AWS region                                                        | string   | n/a     | yes      |
| aws_access_key                        | AWS access key                                                    | string   | n/a     | yes      |
| aws_secret_key                        | AWS secret key                                                    | string   | n/a     | yes      |
| region                                | ibm cloud region                                                  | string   | us-south     | yes      |
| resource_group                        | Resource Group Name that has to be targeted                       | string   | default     | yes      |
| ami                                   | ID of AMI to use for the instance                                 | string   | ami-065ec1e661d619058     | yes      |
| instance_type                         | The type of instance to start                                     | string   | m5d.2xlarge     | yes      |
| vm_prefix                             | Name to be used on all resources as prefix                        | string   | sat     | yes      |
| volume_size                           | EC2 volume size                                                   | number   | 10     | yes      |
| key_name                              | The key name to use for the instance                              | string   | aws_ssh_key    | yes      |
| ssh_public_key                        | SSH Public key for the instance                                   | string   | n/a     | yes      |
| instance_count                        | Number of instances to launch                                     | number   | 3     | yes      |
| tags                                  | A mapping of tags to assign to the resource                       | map(string)   | {"env": "aws"}    | yes      |
| assign_host_count                     | Number of instances to attach to teh location                     | number   | 3     | yes      |
| host_zone                             | location zone                                                     | string   | us-east     | yes      |

