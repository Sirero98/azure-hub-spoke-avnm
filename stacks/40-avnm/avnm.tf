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