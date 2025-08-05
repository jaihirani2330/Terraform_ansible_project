variable "humber_id" {
  description = "Last 4 digits of Humber ID"
  type        = string
  default     = "4294"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "Canada Central"
}

variable "admin_username" {
  description = "Admin username for VMs"
  type        = string
  default     = "azureuser"
}

variable "vm_size" {
  description = "VM SKU"
  type        = string
  default     = "Standard_B1ms"
}

variable "vm_count" {
  description = "Number of VMs to create"
  type        = number
  default     = 3
}

variable "data_disk_size" {
  description = "Data disk size in GB"
  type        = number
  default     = 10
}

variable "project_tags" {
  description = "Project tags"
  type        = map(string)
  default = {
    Project        = "CCGC 5502 Automation Project"
    Name           = "Jai.Hirani"
    ExpirationDate = "2024-12-31"
    Environment    = "Project"
  }
}
