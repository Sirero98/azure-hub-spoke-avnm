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