output "vnet_onprem_id" {
  description = "ID of the simulated on-premises virtual network"
  value       = azurerm_virtual_network.onprem.id
}

output "vpn_gateway_onprem_public_ip" {
  description = "Public IP address of the on-premises VPN gateway"
  value       = module.vpn_gateway.public_ip_address
}
