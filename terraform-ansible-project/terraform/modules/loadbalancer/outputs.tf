output "backend_pool_id" {
  value = azurerm_lb_backend_address_pool.main.id
}

output "public_ip_address" {
  value = azurerm_public_ip.main.ip_address
}

output "fqdn" {
  value = azurerm_public_ip.main.fqdn
}
