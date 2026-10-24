# Without this, traffic from on-premises reaches the spokes directly through the
# peering, while the replies go through the firewall (asymmetric routing → dropped).
resource "azurerm_route_table" "gateway" {
  name                          = "rt-gateway-subnet"
  resource_group_name           = data.azurerm_resource_group.rg.name
  location                      = data.azurerm_resource_group.rg.location
  bgp_route_propagation_enabled = true # required on the GatewaySubnet

  dynamic "route" {
    for_each = var.spoke_address_spaces
    content {
      name                   = "to-spoke-${replace(route.value, "/", "-")}"
      address_prefix         = route.value
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = azurerm_firewall.fw.ip_configuration[0].private_ip_address
    }
  }

  tags = local.tags
}

resource "azurerm_subnet_route_table_association" "gateway" {
  subnet_id      = azurerm_subnet.hub["GatewaySubnet"].id
  route_table_id = azurerm_route_table.gateway.id
}