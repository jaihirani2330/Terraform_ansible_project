# Null resource to run Ansible playbook
resource "null_resource" "ansible_provisioner" {
  depends_on = [
    azurerm_linux_virtual_machine.vm,
    azurerm_virtual_machine_data_disk_attachment.data,
    local_file.ansible_inventory
  ]

  triggers = {
    vm_ids = join(",", azurerm_linux_virtual_machine.vm[*].id)
  }

  provisioner "local-exec" {
    command = <<-EOF
      cd ${path.root}/../ansible
      sleep 120
      ansible-playbook -i inventory.ini 4294-playbook.yml
    EOF
  }
}
