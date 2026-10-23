resource "azurerm_network_manager_routing_configuration" "this" {
  name               = "rc-hubspoke"
  network_manager_id = azurerm_network_manager.avnm.id
}

resource "azurerm_network_manager_routing_rule_collection" "this" {
  name                          = "rcol-spokes-to-fw"
  routing_configuration_id      = azurerm_network_manager_routing_configuration.this.id
  network_group_ids             = [for g in azurerm_network_manager_network_group.this : g.id]
  bgp_route_propagation_enabled = false
}

resource "azurerm_network_manager_routing_rule" "this" {
  for_each = local.fw_routes

  name               = "rr-${each.key}"
  rule_collection_id = azurerm_network_manager_routing_rule_collection.this.id
  description        = "Route ${each.key} traffic through Azure Firewall"


  destination {
    type    = "AddressPrefix"
    address = each.value
  }

  next_hop {
    type    = "VirtualAppliance"
    address = local.fw_private_ip
  }

}
