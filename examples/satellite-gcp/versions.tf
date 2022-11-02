terraform {
  required_version = ">=0.13"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.90.1"
    }
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 1.47.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.4.0"
    }
  }
}