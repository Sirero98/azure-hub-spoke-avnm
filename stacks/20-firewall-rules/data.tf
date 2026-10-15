data "azurerm_resource_group" "rg" {
  name = local.rg_name
}

data "azurerm_firewall_policy" "fw_policy" {
  name                = local.fw_policy_name
  resource_group_name = data.azurerm_resource_group.rg.name
}