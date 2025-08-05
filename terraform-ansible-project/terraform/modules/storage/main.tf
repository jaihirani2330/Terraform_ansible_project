# Storage Account
resource "azurerm_storage_account" "main" {
  name                     = "sa${var.humber_id}automation"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.tags
}

# Storage Container
resource "azurerm_storage_container" "main" {
  name                  = "automation-container"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}
