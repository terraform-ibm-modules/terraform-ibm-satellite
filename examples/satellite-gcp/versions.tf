terraform {
  required_version = ">=0.13"
  required_providers {
    google = {
      source = "hashicorp/google"
    }
    ibm = {
      source = "ibm-cloud/ibm"
    }
  }
}