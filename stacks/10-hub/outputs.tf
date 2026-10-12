output "vnet_hub_id" {
  description = "The ID of the hub virtual network"
  value       = azurerm_virtual_network.vnet_hub.id
}

output "vnet_hub_subnet_ids" {
  description = "The IDs of the hub subnets"
  value       = { for s in azurerm_subnet.hub : s.name => s.id }
}