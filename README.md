# IBM Cloud Satellite Module

This is a collection of modules that make it easier to provision a satellite on IBM Cloud Platform:
* [satellite-location](modules/satellite_location)
* [satellite-cluster](modules/satellite_cluster)
* [satellite-aws](examples/satellite-aws)

## Compatibility

This module is meant for use with Terraform 0.12. 

## Requirements

### Terraform plugins

- [Terraform](https://www.terraform.io/downloads.html) 0.12
- [terraform-provider-ibm](https://github.com/IBM-Cloud/terraform-provider-ibm) 

## Install

### Terraform

Be sure you have the correct Terraform version (0.12), you can choose the binary here:
- https://releases.hashicorp.com/terraform/

### Terraform plugins

Be sure you have the compiled plugins on $HOME/.terraform.d/plugins/

- [terraform-provider-ibm](https://github.com/IBM-Cloud/terraform-provider-ibm) 
