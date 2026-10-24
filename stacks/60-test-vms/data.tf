data "azurerm_resource_group" "rg" {
  name = local.rg_name
}

data "azurerm_subnet" "vm" {
  for_each = var.vms

  name                 = each.value.subnet
  virtual_network_name = each.value.vnet
  resource_group_name  = data.azurerm_resource_group.rg.name
}
