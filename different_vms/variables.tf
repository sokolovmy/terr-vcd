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

variable "vms" {
  description = "Virtual machines params"
  type = list(object({
    ip = string
    name = string
    cpus = optional(number)
    memory = optional(number) # Size in Megabytes
    disk = optional(number) # Size in Gigabytes
    user_data = optional(string)
  }))
}