# Public IPs for VMs
resource "azurerm_public_ip" "vm" {
  count               = var.vm_count
  name                = "pip-vm${count.index + 1}-${var.humber_id}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                = "Standard"
  domain_name_label   = "vm${count.index + 1}-automation-${var.humber_id}"
  tags                = var.tags
}

# Network Interfaces
resource "azurerm_network_interface" "vm" {
  count               = var.vm_count
  name                = "nic-vm${count.index + 1}-${var.humber_id}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm[count.index].id
  }
}

# Associate NSG to NICs
resource "azurerm_network_interface_security_group_association" "vm" {
  count                     = var.vm_count
  network_interface_id      = azurerm_network_interface.vm[count.index].id
  network_security_group_id = var.network_security_group_id
}

# Data Disks
resource "azurerm_managed_disk" "data" {
  count                = var.vm_count
  name                 = "disk-data-vm${count.index + 1}-${var.humber_id}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.data_disk_size
  tags                 = var.tags
}

# Virtual Machines
resource "azurerm_linux_virtual_machine" "vm" {
  count               = var.vm_count
  name                = "vm${count.index + 1}-${var.humber_id}"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username
  tags                = var.tags

  disable_password_authentication = false
  admin_password                  = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.vm[count.index].id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
}

# Attach Data Disks
resource "azurerm_virtual_machine_data_disk_attachment" "data" {
  count              = var.vm_count
  managed_disk_id    = azurerm_managed_disk.data[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.vm[count.index].id
  lun                = "0"
  caching            = "ReadWrite"
}

# Backend Pool Association
resource "azurerm_network_interface_backend_address_pool_association" "vm" {
  count                   = var.vm_count
  network_interface_id    = azurerm_network_interface.vm[count.index].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = var.backend_pool_id
}

# Generate Ansible Inventory
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tpl", {
    vms = [
      for i in range(var.vm_count) : {
        name       = azurerm_linux_virtual_machine.vm[i].name
        public_ip  = azurerm_public_ip.vm[i].ip_address
        private_ip = azurerm_network_interface.vm[i].private_ip_address
        fqdn       = azurerm_public_ip.vm[i].fqdn
      }
    ]
    username = var.admin_username
  })
  filename        = "${path.root}/../ansible/inventory.ini"
  file_permission = "0644"
}

# VM Extension for Azure Monitor Agent
resource "azurerm_virtual_machine_extension" "monitor_agent" {
  count                      = var.vm_count
  name                       = "AzureMonitorLinuxAgent"
  virtual_machine_id         = azurerm_linux_virtual_machine.vm[count.index].id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true

  tags = var.tags
}
