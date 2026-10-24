data "azurerm_resource_group" "rg" {
  name = local.rg_name
}

data "azurerm_resources" "kv" {
  type                = "Microsoft.KeyVault/vaults"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_key_vault_secret" "psk" {
  name         = local.psk_secret_name
  key_vault_id = data.azurerm_resources.kv.resources[0].id
}

data "azurerm_virtual_network_gateway" "hub" {
  name                = local.vpngw_hub_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_public_ip" "vpngw_hub" {
  name                = "pip-${local.vpngw_hub_name}"
  resource_group_name = data.azurerm_resource_group.rg.name
}
