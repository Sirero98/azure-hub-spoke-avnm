output "vnet_name" {
  description = "The name of the virtual network"
  value       = azurerm_virtual_network.this.name
}

output "vnet_id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.this.id
}

output "subnet_id" {
  description = "The ID of the workload subnet"
  value       = azurerm_subnet.this.id
}