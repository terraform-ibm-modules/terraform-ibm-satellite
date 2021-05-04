# satellite-azure

Use this terrafrom automation to set up satellite location on IBM cloud with Azure host.

This example cover end-to-end functionality of IBM cloud satellite by creating satellite location on specified zone. 
It will provision Azure host and assign it to setup location control plane.


#### Example uses below 3 terraform modules to set up the satellite on Azure:

1. [satellite-location](main.tf) This module `creates satellite location` for the specified zone|location|region and `generates script` named addhost.sh in the home directory.
2. [azurerm_linux_virtual_machine](instance.tf) This resouurce will provision Azure linux virtual machine instance, uses the generated script in module as `custom_data` and runs the script. At this stage all the VMs that has run addhost.sh will be attached to the satellite location and will be in unassigned state.
3. [satellite-host](host.tf) This module assigns Azure hosts to the location control plane.

## Compatibility

This module is meant for use with Terraform 0.13 or later. 

## Requirements

### Terraform plugins

- [Terraform](https://www.terraform.io/downloads.html) 0.13 or later. 
- [terraform-provider-ibm](https://github.com/IBM-Cloud/terraform-provider-ibm)
- [terraform-provider-azurerm](https://github.com/terraform-providers/terraform-provider-azurerm)
- To authenticate azure provider please refer [docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret)

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
  ibm_region        = var.ibm_region
  resource_group    = var.ibm_resource_group
  host_provider     = "azure"
  ibmcloud_api_key  = ""
}

resource "azurerm_linux_virtual_machine" "az_host" {
  depends_on            = [data.azurerm_resource_group.resource_group, module.satellite-location]
  count                 = var.satellite_host_count + var.addl_host_count
  name                  = "${var.az_resource_prefix}-vm-${count.index}"
  resource_group_name   = data.azurerm_resource_group.resource_group.name
  location              = data.azurerm_resource_group.resource_group.location
  size                  = var.instance_type
  admin_username        = "adminuser"
  custom_data           = base64encode(module.satellite-location.host_script)
  network_interface_ids = [azurerm_network_interface.az_nic[count.index].id]

  zone = element(local.zones, count.index)
  admin_ssh_key {
    username   = "adminuser"
    public_key = var.ssh_public_key != null ? var.ssh_public_key : tls_private_key.rsa_key.0.public_key_openssh
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 128
  }
  source_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "7-LVM"
    version   = "latest"
  }
}

module "satellite-host" {
  source = "../../modules/host"

  host_count     = var.satellite_host_count
  location       = module.satellite-location.location_id
  host_vms       = azurerm_linux_virtual_machine.az_host.*.name
  location_zones = var.location_zones
  host_labels    = var.host_labels
  host_provider  = "azure"
}
...
```

## Note

* `satellite-location` module creates new location or use existing location ID/name to process. If user pass the location which is already exist,   satellite-location module will error out and exit the module. In such cases user has to set `is_location_exist` value to true. So that module will use existing location for processing.
* `satellite-location` module download attach host script to the $HOME directory and appends respective permissions to the script.
* `satellite-location` module will update the attach host script and will be used in the `custom_data` attribute of `azurerm_linux_virtual_machine` resource.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name                                  | Description                                                       | Type     | Default | Required |
|---------------------------------------|-------------------------------------------------------------------|----------|---------|----------|
| ibmcloud_api_key                      | IBM Cloud API Key                                                 | string   | n/a     | yes      |
| ibm_region                            | Region of the IBM Cloud account. Currently supported regions for satellite are `us-east` and `eu-gb` region. | string   | us-east | yes      |
| ibm_resource_group                    | IBM Resource group name that has to be targeted                   | string   | n/a     | yes       |
| subscription_id                       | Subscription id of Azure Account                                  | string   | n/a     | yes      |
| client_id                             | Client id of Azure Account                                        | string   | n/a     | yes      |
| tenant_id                             | Tenent id of Azure Account                                        | string   | n/a     | yes   |
| client_secret                         | Client Secret of Azure Account                                    | string   | n/a     | yes      |
| is_az_resource_group_exist            | "If false, resource group (az_resource_group) will be created. If true, existing resource group (az_resource_group) will be read"| bool   | false  | yes   |
| az_resource_group                     | Azure Resource Group                                              | string  | satellite-azure  | yes   |
| az_region                             | Azure Region                                                      | string   | eastus  | yes   |
| location                              | Name of the Location that has to be created                       | string   | satellite-azure | yes   |
| is_location_exist                     | Determines if the location has to be created or not               | bool     | false   | yes      |
| managed_from                          | The IBM Cloud region to manage your Satellite location from.      | string   | wdc   | yes      |
| location_zones                        | Allocate your hosts across three zones for higher availablity     | list     | ["us-east-1", "us-east-2", "us-east-3"]    | yes      | 
| host_labels                                | Add labels to attach host script                                  | list     | [env:prod]  | no   |
| location_bucket                       | COS bucket name                                                   | string   | n/a     | no       |
| az_resource_prefix                       | Name to be used on all azure resources as prefix                        | string   | satellite-azure     | yes |
| satellite_host_count                  | The total number of azure host to create for control plane. satellite_host_count value should always be in multiples of 3, such as 3, 6, 9, or 12 hosts                 | number   | 3 |  yes     |
| addl_host_count                       | The total number of additional azure host                            | number   | 0 |  yes     |
|instance_type|The type of azure instance to start|string|Standard_D4s_v3|yes|
| ssh_public_key                        | SSH Public Key. Get your ssh key by running `ssh-key-gen` command | string   | n/a     | no |


## Outputs

| Name | Description |
|------|-------------|
| location_id | location ID value |
| host_ids | ID's of Azure Hosts |