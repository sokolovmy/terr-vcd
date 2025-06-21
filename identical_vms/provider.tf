# Connection for the VMware vCloud Director Provider
terraform {
  # required_version = ">= 1.3, <= 1.9.8"
  required_providers {
    vcd = {
      source  = "vmware/vcd"
      version = "3.14.1"
    }
  }
}

provider "vcd" {
  user = "none"
  password = "none"
  auth_type = "api_token"
  api_token = var.api_token
  url = var.vcd_url
  org = var.vcd_org
  vdc = var.vcd_vdc
  max_retry_timeout = var.vcd_max_retry_timeout
  allow_unverified_ssl = var.vcd_allow_unverified_ssl
}
