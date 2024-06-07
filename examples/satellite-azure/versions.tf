terraform {
  required_version = ">=0.13, <1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.97.0"
    }
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 1.64.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.4.0"
    }
  }
}
