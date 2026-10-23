module "vm" {
  source   = "../../modules/linux-vm"
  for_each = var.vms

  name                 = "vm-${each.key}"
  resource_group_name  = data.azurerm_resource_group.rg.name
  location             = data.azurerm_resource_group.rg.location
  subnet_id            = data.azurerm_subnet.vm[each.key].id
  admin_ssh_public_key = file(pathexpand(var.ssh_public_key_path))
  custom_data          = templatefile("${path.module}/cloud-init.yaml", { vm_name = "vm-${each.key}" })
  tags                 = local.tags
}