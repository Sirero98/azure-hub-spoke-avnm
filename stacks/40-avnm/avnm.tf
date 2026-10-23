resource "azurerm_network_manager" "avnm" {
  name                = local.avnm_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  scope {
    subscription_ids = ["/subscriptions/${var.subscription_id}"]
  }
  scope_accesses = ["Connectivity", "Routing"]

  tags = local.tags

}

resource "azurerm_network_manager_network_group" "this" {
  for_each = toset(values(var.spokes))

  name               = "ng-${each.key}"
  network_manager_id = azurerm_network_manager.avnm.id
}

resource "azurerm_network_manager_static_member" "spokes" {
  for_each = var.spokes

  name                      = "sm-${each.key}"
  network_group_id          = azurerm_network_manager_network_group.this[each.value].id
  target_virtual_network_id = data.azurerm_virtual_network.spokes[each.key].id
}

resource "azurerm_network_manager_connectivity_configuration" "this" {
  name                  = "cc-hubspoke"
  network_manager_id    = azurerm_network_manager.avnm.id
  connectivity_topology = "HubAndSpoke"
  
  hub {
    resource_id   = data.azurerm_virtual_network.hub.id
    resource_type = "Microsoft.Network/virtualNetworks"
  }

  dynamic "applies_to_group" {
    for_each = azurerm_network_manager_network_group.this
    content {
      group_connectivity = "None"
      use_hub_gateway    = true
      network_group_id   = applies_to_group.value.id
    }
  }
}