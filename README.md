# IBM Cloud Satellite Module

This is a collection of modules that make it easier to provision a satellite on IBM Cloud Platform:
* [satellite-location](modules/location)
* [satellite-host](modules/host)

## Overview
Deployment of 'Satelite on IBM Cloud' is divided into separate steps.
	
* Step 1: You can create Satellite locations for each place that you like, such as your company's ports in the north and south of the country. After you set up your locations, you can bring IBM Cloud services and consistent application management to the machines that already exist in your environments in the location.
  
* Step 2: After you create the location, you must add compute capacity to your location so that you can run the Satellite control plane or set up OpenShift clusters.<br>
you can add hosts that you run in your on-prem data center, in IBM Cloud, or in other cloud providers. Make sure that your host has public network connectivity and that you have access to the host machine to run the Satellite script.
  
* Step 3: Log in to each host machine that you want to add to your location and run the script. The steps for how to log in to your machine and run the script vary by cloud provider. When you run the script on the machine, the machine is made visible to your Satellite location, but is not yet assigned to the Satellite control plane or a Satellite cluster. The script also disables the ability to SSH in to the machine for security purposes. If you later remove the host from the Satellite location, you must reload the host machine to SSH into the machine again

* Step 4: Setup Satellite Control Plane. The Satellite control plane serves as the .... TODO. To create the control plane, you must add at least 3 compute hosts to your location that meet the [minimum requirements](https://cloud.ibm.com/docs/satellite?topic=satellite-host-reqs) . Assign these hosts to your location.

* Step 5: Create DNS for your new Location.

## Compatibility

This module is meant for use with Terraform 0.13. 

## Requirements

### Terraform plugins

- [Terraform](https://www.terraform.io/downloads.html) 0.13
- [terraform-provider-ibm](https://github.com/IBM-Cloud/terraform-provider-ibm) 

## Install

### Terraform

Be sure you have the correct Terraform version (0.13), you can choose the binary here:
- https://releases.hashicorp.com/terraform/

### Terraform plugins

Be sure you have the compiled plugins on $HOME/.terraform.d/plugins/

- [terraform-provider-ibm](https://github.com/IBM-Cloud/terraform-provider-ibm) 
