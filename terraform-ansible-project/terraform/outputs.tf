output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "vm_public_ips" {
  value = module.compute.vm_public_ips
}

output "vm_private_ips" {
  value = module.compute.vm_private_ips
}

output "vm_fqdns" {
  value = module.compute.vm_fqdns
}

output "load_balancer_ip" {
  value = module.loadbalancer.public_ip_address
}

output "load_balancer_fqdn" {
  value = module.loadbalancer.fqdn
}

output "ssh_private_key_path" {
  value = local_file.ssh_private_key.filename
}
