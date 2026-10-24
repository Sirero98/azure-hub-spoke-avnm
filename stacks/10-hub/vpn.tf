module "vpn_gateway" {
  source = "../../modules/vpn-gateway"

  name                = local.vpngw_hub_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  gateway_subnet_id   = azurerm_subnet.hub["GatewaySubnet"].id
  tags                = local.tags
}
