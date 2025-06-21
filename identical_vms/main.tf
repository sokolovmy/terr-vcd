resource "vcd_vapp" "vapp" {
  name     = var.vapp_name
  power_on = true
}

resource "vcd_vapp_org_network" "routed_network" {
  vapp_name = vcd_vapp.vapp.name
  org_network_name = var.routed_network_name
  reboot_vapp_on_removal = true
}

module "vms" {
  source = "../modules/vm"
  count = var.vms_count
  vapp_name = vcd_vapp.vapp.name
  name = format("%s%02d", var.vm_name_prefix, count.index + 1)
  ip = cidrhost(var.vm_ip_base, var.vm_ip_start + count.index)
  org_network_name = vcd_vapp_org_network.routed_network.org_network_name
}