# Random password for VMs
resource "random_password" "vm_password" {
  length  = 16
  special = true
}

# SSH Key Pair
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save SSH private key locally
resource "local_file" "ssh_private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.root}/../ansible/ssh_private_key.pem"
  file_permission = "0600"
}

# Data source for current client config
data "azurerm_client_config" "current" {}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-automation-${var.humber_id}"
  location = var.location
  tags     = var.project_tags
}

# Azure Key Vault for storing secrets
resource "azurerm_key_vault" "main" {
  name                = "kv-automation-${var.humber_id}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  tags                = var.project_tags
}

# Key Vault Access Policy
resource "azurerm_key_vault_access_policy" "main" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get", "List", "Set", "Delete", "Recover", "Backup", "Restore"
  ]
}

# Key Vault Secret for VM Password
resource "azurerm_key_vault_secret" "vm_password" {
  name         = "vm-admin-password"
  value        = random_password.vm_password.result
  key_vault_id = azurerm_key_vault.main.id
  depends_on   = [azurerm_key_vault_access_policy.main]
}

# Application Security Group for Web Servers
resource "azurerm_application_security_group" "webservers" {
  name                = "asg-webservers-${var.humber_id}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.project_tags
}

# Application Security Group for Database Servers
resource "azurerm_application_security_group" "database" {
  name                = "asg-database-${var.humber_id}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.project_tags
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-automation-${var.humber_id}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.project_tags
}

# Application Insights
resource "azurerm_application_insights" "main" {
  name                = "ai-automation-${var.humber_id}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "web"
  tags                = var.project_tags
}

# Recovery Services Vault
resource "azurerm_recovery_services_vault" "main" {
  name                = "rsv-automation-${var.humber_id}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"
  tags                = var.project_tags
}

# Backup Policy
resource "azurerm_backup_policy_vm" "main" {
  name                = "bp-daily-${var.humber_id}"
  resource_group_name = azurerm_resource_group.main.name
  recovery_vault_name = azurerm_recovery_services_vault.main.name

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 7
  }
}

# Route Table for custom routing
resource "azurerm_route_table" "main" {
  name                = "rt-automation-${var.humber_id}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.project_tags

  route {
    name           = "DefaultRoute"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }
}

# Route Table Association
resource "azurerm_subnet_route_table_association" "main" {
  subnet_id      = module.networking.subnet_id
  route_table_id = azurerm_route_table.main.id
}

# HTTPS Security Rule (standalone)
resource "azurerm_network_security_rule" "https" {
  name                        = "HTTPS"
  priority                    = 1003
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = module.networking.network_security_group_name
}

# Project documentation file 
resource "local_file" "project_info" {
  content = <<-EOF
    Terraform + Ansible Automation Project
    =====================================
    
    Student: Jai Hirani
    Humber ID: n01714294
    Project ID: 4294
    
    Infrastructure Details:
    - Resource Group: ${azurerm_resource_group.main.name}
    - Location: ${var.location}
    - VMs Created: ${var.vm_count}
    - Project Tags: ${jsonencode(var.project_tags)}
    
    Created: ${timestamp()}
  EOF
  
  filename        = "${path.root}/project-info-${var.humber_id}.txt"
  file_permission = "0644"
}

# Networking Module
module "networking" {
  source              = "./modules/networking"
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  humber_id          = var.humber_id
  tags               = var.project_tags
}

# Storage Module
module "storage" {
  source              = "./modules/storage"
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  humber_id          = var.humber_id
  tags               = var.project_tags
}

# Load Balancer Module
module "loadbalancer" {
  source              = "./modules/loadbalancer"
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  humber_id          = var.humber_id
  tags               = var.project_tags
  subnet_id          = module.networking.subnet_id
}

# Compute Module
module "compute" {
  source                    = "./modules/compute"
  resource_group_name      = azurerm_resource_group.main.name
  location                = azurerm_resource_group.main.location
  humber_id               = var.humber_id
  tags                    = var.project_tags
  subnet_id               = module.networking.subnet_id
  network_security_group_id = module.networking.network_security_group_id
  vm_count                = var.vm_count
  vm_size                 = var.vm_size
  admin_username          = var.admin_username
  admin_password          = random_password.vm_password.result
  ssh_public_key          = tls_private_key.ssh_key.public_key_openssh
  data_disk_size          = var.data_disk_size
  backend_pool_id         = module.loadbalancer.backend_pool_id
}
