# IBM Cloud Satellite Module

This is a collection of modules that make it easier to provision a satellite on IBM Cloud Platform:
* [satellite-location](modules/location)
* [ec2](examples/satellite-aws/instance.tf)
* [satellite-host](modules/host)
* [satellite-cluster](modules/cluster)
* [satellite-cluster-host](modules/cluster_host)

## Overview
IBM Cloud® Satellite helps you deploy and run applications consistently across all on-premises, edge computing and public cloud environments from any cloud vendor. It standardizes a core set of Kubernetes, data, AI and security services to be centrally managed as a service by IBM Cloud, with full visibility across all environments through a single pane of glass. The result is greater developer productivity and development velocity.

https://cloud.ibm.com/docs/satellite?topic=satellite-getting-started

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
