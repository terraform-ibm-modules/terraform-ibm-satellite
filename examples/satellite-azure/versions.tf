terraform {
  required_version = ">=0.13"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    ibm = {
      source = "ibm-cloud/ibm"
    }
  }
}