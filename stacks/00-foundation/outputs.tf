output "rg_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "rg_id" {
  description = "The ID of the resource group"
  value       = azurerm_resource_group.rg.id
}

output "rg_location" {
  description = "The location of the resource group"
  value       = azurerm_resource_group.rg.location
}

output "vnet_hub_id" {
  description = "The ID of the hub virtual network"
  value       = azurerm_virtual_network.vnet_hub.id
}

output "vnet_hub_subnet_ids" {
  description = "The IDs of the hub subnets"
  value       = { for s in azurerm_subnet.hub : s.name => s.id }
}

output "spokes" {
  description = "Spoke VNets keyed by spoke name, with their IDs and environment"
  value = {
    for name, spoke in module.spoke : name => {
      vnet_id   = spoke.vnet_id
      vnet_name = spoke.vnet_name
      subnet_id = spoke.subnet_id
      env       = var.spokes[name].env
    }
  }
}