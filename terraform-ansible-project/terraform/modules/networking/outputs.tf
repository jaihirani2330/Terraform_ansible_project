output "virtual_network_id" {
  value = azurerm_virtual_network.main.id
}

output "subnet_id" {
  value = azurerm_subnet.internal.id
}

output "network_security_group_id" {
  value = azurerm_network_security_group.main.id
}

output "network_security_group_name" {
  value = azurerm_network_security_group.main.name
}
