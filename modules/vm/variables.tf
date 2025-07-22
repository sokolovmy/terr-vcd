
variable "name" {
  description = "VM name"
  type        = string
}

variable "vapp_name" {
  description = "VApp name"
}

variable "memory" {
  description = "VM memory size"
  type = number
  default = 4096
}

variable "cpus" {
  description = "VM cpus"
  type = number
  default = 4
}

variable "disk" {
  description = "VM disk size (Gigabytes)"
  type = number
  default = 20
}

variable "vapp_template_id" {
  description = "vCD vApp Template ID"
  type        = string
  default = null
}


variable "org_network_name" {
  description = "vCD Org Network Name"
  type        = string
}

variable "ip" {
  description = "IP address for the VM"
  type        = string
}

variable "user_data" {
  description = "User data for the VM (base64 encoded string)"
  type        = string
  default     = null
}


variable "vcd_catalog_name" {
  description = "vCD Catalog Name where the vApp Template is stored"
  type        = string
  default     = "Cloud MON"
}

variable "vcd_catalog_template_name" {
  description = "template vm name in the vCD catalog"
  type        = string
  default     = "(LVM) Ubuntu 22.04 Server (20250702)"


}

variable "default_user_data_file" {
  description = "Default user data for the vm (path to file)"
  type = string
  default = "user-data.yaml"
}
