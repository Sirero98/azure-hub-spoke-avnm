# ── Local network gateways: each one describes the OTHER side ──

# Used by on-prem: the hub is at this IP and has these networks behind it
resource "azurerm_local_network_gateway" "hub" {
  name                = "lng-hub"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  gateway_address     = data.azurerm_public_ip.vpngw_hub.ip_address
  address_space       = var.azure_address_spaces
  tags                = local.tags
}

# Used by the hub: on-prem is at this IP and has this network behind it
resource "azurerm_local_network_gateway" "onprem" {
  name                = "lng-onprem"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  gateway_address     = module.vpn_gateway.public_ip_address
  address_space       = [var.onprem_address_space]
  tags                = local.tags
}

# ── Connections: local gateway + LNG describing the remote side ──

resource "azurerm_virtual_network_gateway_connection" "onprem_to_hub" {
  name                = "cn-onprem-to-hub"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  type                       = "IPsec"
  virtual_network_gateway_id = module.vpn_gateway.id
  local_network_gateway_id   = azurerm_local_network_gateway.hub.id
  shared_key                 = data.azurerm_key_vault_secret.psk.value

  tags = local.tags
}

resource "azurerm_virtual_network_gateway_connection" "hub_to_onprem" {
  name                = "cn-hub-to-onprem"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  type                       = "IPsec"
  virtual_network_gateway_id = data.azurerm_virtual_network_gateway.hub.id
  local_network_gateway_id   = azurerm_local_network_gateway.onprem.id
  shared_key                 = data.azurerm_key_vault_secret.psk.value

  tags = local.tags
}
