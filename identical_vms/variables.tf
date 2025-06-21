variable "api_token" {
  description = "vCD Tenant User API Token"
  type        = string
}

variable "vcd_org" {
  description = "vCD Tenant Org"
  type        = string
}

variable "vcd_url" {
  description = "vCD Tenant URL"
  type        = string
}

variable "vcd_vdc" {
  description = "vCD Tenant VDC"
  type        = string
}

variable "vcd_max_retry_timeout" {
  description = "Retry Timeout"
  type        = string
  default     = "300"
}

variable "vcd_allow_unverified_ssl" {
  description = "vCD allow unverified SSL"
  type        = string
  default     = "false"
}

variable "routed_network_name" {
  description = "Routed network name"
  type        = string
}

variable "vapp_name" {
  description = "VApp name"
}


variable "vm_name_prefix" {
  description = "Prefix for VM names"
  type        = string
}

variable "vm_ip_base" {
  description = "Base network for IP addresses (e.g., '192.168.1.0/24')"
  type        = string
}

variable "vm_ip_start" {
  description = "Starting IP offset (e.g., 10 for 192.168.1.10)"
  type        = number
}

variable "vms_count" {
  description = "Number of VMs to create"
  type        = number
  default     = 2
  
}