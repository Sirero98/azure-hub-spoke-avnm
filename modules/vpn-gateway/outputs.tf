output "id" {
  description = "The ID of the VPN Gateway."
  value       = azurerm_virtual_network_gateway.this.id
}

output "public_ip_address" {
  description = "The public IP address of the VPN Gateway."
  value       = azurerm_public_ip.this.ip_address
}
