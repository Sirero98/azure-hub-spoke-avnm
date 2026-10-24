output "vnet_hub_id" {
  description = "The ID of the hub virtual network"
  value       = azurerm_virtual_network.vnet_hub.id
}

output "vnet_hub_subnet_ids" {
  description = "The IDs of the hub subnets"
  value       = { for s in azurerm_subnet.hub : s.name => s.id }
}

output "fw_private_ip" {
  description = "The private IP address of the firewall"
  value       = azurerm_firewall.fw.ip_configuration[0].private_ip_address
}

output "vpn_gateway_hub_id" {
  description = "The ID of the VPN Gateway in the hub"
  value       = module.vpn_gateway.id
}

output "vpn_gateway_hub_public_ip" {
  description = "The public IP address of the VPN Gateway in the hub"
  value       = module.vpn_gateway.public_ip_address
}
