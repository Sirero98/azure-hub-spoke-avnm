resource "azurerm_public_ip" "pip_fw" {
  name                = local.pip_fw_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
  tags                = local.tags
}

resource "azurerm_public_ip" "pip_fw_mgmt" {
  name                = local.pip_fw_mgmt_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
  tags                = local.tags
}

resource "azurerm_firewall_policy" "fw_policy" {
  name                = local.fw_policy_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "Basic"
  tags                = local.tags
}

resource "azurerm_firewall" "fw" {
  name                = local.fw_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Basic"
  zones               = ["1", "2", "3"]
  firewall_policy_id  = azurerm_firewall_policy.fw_policy.id

  ip_configuration {
    name                 = "ipconfig-fw"
    subnet_id            = azurerm_subnet.hub["AzureFirewallSubnet"].id
    public_ip_address_id = azurerm_public_ip.pip_fw.id
  }

  management_ip_configuration {
    name                 = "ipconfig-fw-mgmt"
    subnet_id            = azurerm_subnet.hub["AzureFirewallManagementSubnet"].id
    public_ip_address_id = azurerm_public_ip.pip_fw_mgmt.id
  }

  tags = local.tags
}