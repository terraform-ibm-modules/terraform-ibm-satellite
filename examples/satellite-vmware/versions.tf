terraform {
  required_version = ">= 1.1.9"
  required_providers {
    vcd = {
      source  = "vmware/vcd"
      version = ">= 3.10.0"
    }
  }
}
