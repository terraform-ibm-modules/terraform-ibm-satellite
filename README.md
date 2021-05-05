# IBM Cloud Satellite Module

This is a collection of modules that make it easier to provision a satellite on IBM Cloud Platform:
* [satellite-location](modules/location)
* [ec2](examples/satellite-aws/instance.tf)
* [satellite-host](modules/host)


## Overview
IBM Cloud® Satellite helps you deploy and run applications consistently across all on-premises, edge computing and public cloud environments from any cloud vendor. It standardizes a core set of Kubernetes, data, AI and security services to be centrally managed as a service by IBM Cloud, with full visibility across all environments through a single pane of glass. The result is greater developer productivity and development velocity.

https://cloud.ibm.com/docs/satellite?topic=satellite-getting-started

## Compatibility

This module is meant for use with Terraform 0.13 or later.

## NOTE:

If we want to make use of a particular version of module, then set the argument "version" to respective module version.

## Requirements

### Terraform plugins

- [Terraform](https://www.terraform.io/downloads.html) 0.13 or later.
- [terraform-provider-ibm](https://github.com/IBM-Cloud/terraform-provider-ibm)

## Install

### Terraform

Be sure you have the correct Terraform version (0.13 or later ), you can choose the binary here:
- https://releases.hashicorp.com/terraform/

### Terraform provider plugins

Be sure you have the compiled plugins on $HOME/.terraform.d/plugins/

- [terraform-provider-ibm](https://github.com/IBM-Cloud/terraform-provider-ibm)

### Pre-commit Hooks

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

## Note

All optional fields should be given value `null` in respective resource varaible.tf file. User can configure the same by overwriting with appropriate values.