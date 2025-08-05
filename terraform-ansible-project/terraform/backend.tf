terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state-4294"
    storage_account_name = "saterraformstate4294"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
