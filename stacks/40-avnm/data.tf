data "azurerm_resource_group" "rg" {
  name = local.rg_name
}

data "azurerm_virtual_network" "spokes" {
  for_each = var.spokes

  name                = "vnet-${each.key}"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_virtual_network" "hub" {
  name                = local.vnet_hub_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "fw" {
  name                 = "AzureFirewallSubnet"
  virtual_network_name = data.azurerm_virtual_network.hub.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}
