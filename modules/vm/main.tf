
data "vcd_catalog" "cloud-mon" {
  name = var.vcd_catalog_name
}

data "vcd_catalog_vapp_template" "tpl" {
  catalog_id = data.vcd_catalog.cloud-mon.id
  name = var.vcd_catalog_template_name
}


resource "vcd_vapp_vm" "vm_name" {

  vapp_name        = var.vapp_name
  name             = var.name
  computer_name    = var.name
  memory           = coalesce(var.memory, 2048)
  cpus             = coalesce(var.cpus, 2)
  cpu_cores        = 1
  vapp_template_id = coalesce(
    var.vapp_template_id,
    data.vcd_catalog_vapp_template.tpl.id
  )

  network {
    type               = "org"
    name               = var.org_network_name
    ip_allocation_mode = "MANUAL"
    ip                 = var.ip
  }

  guest_properties = {
    "local-hostname" = var.name
    "user-data"      = coalesce(
        var.user_data,
        base64encode(file(format("%s/%s", path.module, var.default_user_data_file)))
    )
  }

  override_template_disk {
    bus_type    = "paravirtual"
    bus_number  = 0
    unit_number = 0
    iops        = 0

    size_in_mb = coalesce(var.disk, 20) * 1024
  }

  customization {
    enabled                    = true
    auto_generate_password     = false
    allow_local_admin_password = false
  }

}
