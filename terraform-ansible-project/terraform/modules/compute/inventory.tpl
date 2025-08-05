[webservers]
%{ for vm in vms ~}
${vm.name} ansible_host=${vm.public_ip} ansible_user=${username} ansible_ssh_private_key_file=ssh_private_key.pem ansible_ssh_common_args='-o StrictHostKeyChecking=no' private_ip=${vm.private_ip} fqdn=${vm.fqdn}
%{ endfor ~}

[all:vars]
ansible_python_interpreter=/usr/bin/python3
