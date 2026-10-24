resource "azurerm_ip_group" "this" {
  for_each = var.ip_groups

  name                = "ipg-${each.key}"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  cidrs               = each.value
  tags                = local.tags
}
