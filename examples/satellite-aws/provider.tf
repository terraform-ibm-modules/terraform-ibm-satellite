terraform {
  required_providers {
    ibm = {
      source = "ibm-cloud/ibm"
    }
  }
}

provider "ibm" {
  region           = var.ibm_region
  ibmcloud_api_key = var.ibmcloud_api_key
}


provider "aws" {
  region      = var.aws_region
  access_key  = var.aws_access_key
  secret_key  = var.aws_secret_key
}
