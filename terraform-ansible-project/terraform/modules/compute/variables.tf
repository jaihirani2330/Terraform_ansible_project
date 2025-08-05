variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "humber_id" {
  description = "Last 4 digits of Humber ID"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

variable "subnet_id" {
  description = "Subnet ID for VMs"
  type        = string
}

variable "network_security_group_id" {
  description = "Network Security Group ID"
  type        = string
}

variable "vm_count" {
  description = "Number of VMs to create"
  type        = number
}

variable "vm_size" {
  description = "VM SKU"
  type        = string
}

variable "admin_username" {
  description = "Admin username for VMs"
  type        = string
}

variable "admin_password" {
  description = "Admin password for VMs"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH public key"
  type        = string
}

variable "data_disk_size" {
  description = "Data disk size in GB"
  type        = number
}

variable "backend_pool_id" {
  description = "Load balancer backend pool ID"
  type        = string
}
