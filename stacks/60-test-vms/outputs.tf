output "vm_private_ips" {
  value = { for k, vm in module.vm : k => vm.private_ip }
}