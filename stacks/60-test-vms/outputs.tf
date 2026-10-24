output "vm_private_ips" {
  description = "Private IP address of each test VM"
  value       = { for k, vm in module.vm : k => vm.private_ip }
}
