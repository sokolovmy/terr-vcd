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
  for_each = { for vm in var.vms : vm.name => vm }
  vapp_name = vcd_vapp.vapp.name
  name = each.value.name
  memory = each.value.memory
  cpus = each.value.cpus
  disk = each.value.disk
  # vapp_template_id = data.vcd_catalog_vapp_template.ubunutu22043.id
  org_network_name = vcd_vapp_org_network.routed_network.org_network_name
  ip = each.value.ip
  # user_data = each.value.user_data
}