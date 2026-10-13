data "azurerm_resource_group" "rg" {
  name = local.rg_name
}

data "azurerm_log_analytics_workspace" "law" {
  name                = local.law_name
  resource_group_name = data.azurerm_resource_group.rg.name
}