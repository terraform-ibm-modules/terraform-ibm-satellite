
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
