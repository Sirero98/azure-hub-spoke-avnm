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