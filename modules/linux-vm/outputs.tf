output "id" {
  description = "The Id of the Virtual Machine"
  value       = azurerm_linux_virtual_machine.this.id
}

output "private_ip" {
  description = "The private IP of the NIC"
  value       = azurerm_network_interface.this.private_ip_address
}
