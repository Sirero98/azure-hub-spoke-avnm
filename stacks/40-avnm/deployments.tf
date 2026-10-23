locals {
  avnm_deployments = {
    Connectivity = [azurerm_network_manager_connectivity_configuration.this.id]
    Routing      = [azurerm_network_manager_routing_configuration.this.id]
  }
}

resource "azurerm_network_manager_deployment" "this" {
  for_each = local.avnm_deployments

  network_manager_id = azurerm_network_manager.avnm.id
  location           = data.azurerm_resource_group.rg.location
  scope_access       = each.key
  configuration_ids  = each.value
  triggers = {
    routes = jsonencode(local.fw_routes)
  }

  depends_on = [
    azurerm_network_manager_static_member.spokes,
    azurerm_network_manager_routing_rule.this,
  ]
}