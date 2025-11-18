# ===================================================================
# Compute Module - Variables
# ===================================================================

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure location"
  type        = string
}

variable "vm_name" {
  description = "Virtual machine name"
  type        = string
}

variable "vm_size" {
  description = "VM size (SKU)"
  type        = string
  default     = "Standard_B1s"

  validation {
    condition     = can(regex("^Standard_", var.vm_size))
    error_message = "VM size must start with 'Standard_'."
  }
}

variable "admin_username" {
  description = "Administrator username"
  type        = string
  default     = "azureuser"

  validation {
    condition     = length(var.admin_username) >= 1 && length(var.admin_username) <= 64
    error_message = "Username must be between 1 and 64 characters."
  }
}

variable "ssh_public_key" {
  description = "SSH public key for authentication"
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^ssh-rsa|^ssh-ed25519|^ecdsa-sha2-nistp256", var.ssh_public_key))
    error_message = "Must be a valid SSH public key."
  }
}

variable "disable_password_authentication" {
  description = "Disable password authentication"
  type        = bool
  default     = true
}

variable "nic_name" {
  description = "Network interface name"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the NIC will be connected"
  type        = string
}

variable "public_ip_id" {
  description = "Public IP ID to associate (optional)"
  type        = string
  default     = null
}

variable "nsg_id" {
  description = "Network Security Group ID to associate"
  type        = string
}

variable "os_disk_caching" {
  description = "OS disk cache type"
  type        = string
  default     = "ReadWrite"

  validation {
    condition     = contains(["None", "ReadOnly", "ReadWrite"], var.os_disk_caching)
    error_message = "Cache must be 'None', 'ReadOnly', or 'ReadWrite'."
  }
}

variable "os_disk_storage_account_type" {
  description = "OS disk storage account type"
  type        = string
  default     = "Standard_LRS"

  validation {
    condition     = contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS"], var.os_disk_storage_account_type)
    error_message = "Invalid storage type."
  }
}

variable "image_publisher" {
  description = "OS image publisher"
  type        = string
  default     = "Canonical"
}

variable "image_offer" {
  description = "OS image offer"
  type        = string
  default     = "0001-com-ubuntu-server-jammy"
}

variable "image_sku" {
  description = "OS image SKU"
  type        = string
  default     = "22_04-lts-gen2"
}

variable "image_version" {
  description = "OS image version"
  type        = string
  default     = "latest"
}

variable "tags" {
  description = "Tags to apply to compute resources"
  type        = map(string)
  default     = {}
}
