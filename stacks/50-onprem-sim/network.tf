resource "azurerm_virtual_network" "onprem" {
  name                = local.vnet_onprem_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  address_space       = [var.onprem_address_space]

  tags = local.tags
}

resource "azurerm_subnet" "onprem" {
  for_each = var.onprem_subnets

  name                            = each.key
  resource_group_name             = data.azurerm_resource_group.rg.name
  virtual_network_name            = azurerm_virtual_network.onprem.name
  address_prefixes                = [each.value]
  default_outbound_access_enabled = true
}