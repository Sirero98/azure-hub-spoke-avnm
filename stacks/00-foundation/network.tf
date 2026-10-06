resource "azurerm_virtual_network" "vnet_hub" {
  name                = local.vnet_hub_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.hub_address_space]

  tags = local.tags
}
resource "azurerm_subnet" "hub" {
  for_each = var.hub_subnets

  name                 = each.key
  resource_group_name  = azurerm_virtual_network.vnet_hub.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet_hub.name
  address_prefixes     = [each.value]
}