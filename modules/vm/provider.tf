# Connection for the VMware vCloud Director Provider
terraform {
  required_providers {
    vcd = {
      source  = "vmware/vcd"
      version = "3.14.1"
    }
  }
}
