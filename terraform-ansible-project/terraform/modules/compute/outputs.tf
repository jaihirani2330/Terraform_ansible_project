output "vm_public_ips" {
  value = azurerm_public_ip.vm[*].ip_address
}

output "vm_private_ips" {
  value = azurerm_network_interface.vm[*].private_ip_address
}

output "vm_fqdns" {
  value = azurerm_public_ip.vm[*].fqdn
}
