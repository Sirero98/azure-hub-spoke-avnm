module "spoke" {
  source   = "../../modules/spoke"
  for_each = var.spokes

  name                   = "vnet-${each.key}"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  address_space          = each.value.address_space
  workload_subnet_prefix = each.value.workload_subnet

  tags = merge(local.tags, {
    rol = "spoke-${each.value.env}"
  })
}