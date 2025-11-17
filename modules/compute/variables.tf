# ===================================================================
# Compute Module - Variables
# ===================================================================

variable "resource_group_name" {
  description = "Nombre del grupo de recursos"
  type        = string
}

variable "location" {
  description = "Ubicación de Azure"
  type        = string
}

variable "vm_name" {
  description = "Nombre de la máquina virtual"
  type        = string
}

variable "vm_size" {
  description = "Tamaño de la VM (SKU)"
  type        = string
  default     = "Standard_B1s"

  validation {
    condition     = can(regex("^Standard_", var.vm_size))
    error_message = "El tamaño de VM debe comenzar con 'Standard_'."
  }
}

variable "admin_username" {
  description = "Nombre de usuario administrador"
  type        = string
  default     = "azureuser"

  validation {
    condition     = length(var.admin_username) >= 1 && length(var.admin_username) <= 64
    error_message = "El nombre de usuario debe tener entre 1 y 64 caracteres."
  }
}

variable "ssh_public_key" {
  description = "Clave SSH pública para autenticación"
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^ssh-rsa|^ssh-ed25519|^ecdsa-sha2-nistp256", var.ssh_public_key))
    error_message = "Debe ser una clave SSH pública válida."
  }
}

variable "disable_password_authentication" {
  description = "Deshabilitar autenticación por contraseña"
  type        = bool
  default     = true
}

variable "nic_name" {
  description = "Nombre de la interfaz de red"
  type        = string
}

variable "subnet_id" {
  description = "ID de la subred donde se conectará la NIC"
  type        = string
}

variable "public_ip_id" {
  description = "ID de la IP pública a asociar (opcional)"
  type        = string
  default     = null
}

variable "nsg_id" {
  description = "ID del Network Security Group a asociar"
  type        = string
}

variable "os_disk_caching" {
  description = "Tipo de caché para el disco del SO"
  type        = string
  default     = "ReadWrite"

  validation {
    condition     = contains(["None", "ReadOnly", "ReadWrite"], var.os_disk_caching)
    error_message = "El caché debe ser 'None', 'ReadOnly' o 'ReadWrite'."
  }
}

variable "os_disk_storage_account_type" {
  description = "Tipo de cuenta de almacenamiento para el disco del SO"
  type        = string
  default     = "Standard_LRS"

  validation {
    condition     = contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS"], var.os_disk_storage_account_type)
    error_message = "Tipo de almacenamiento no válido."
  }
}

variable "image_publisher" {
  description = "Publisher de la imagen del SO"
  type        = string
  default     = "Canonical"
}

variable "image_offer" {
  description = "Offer de la imagen del SO"
  type        = string
  default     = "0001-com-ubuntu-server-jammy"
}

variable "image_sku" {
  description = "SKU de la imagen del SO"
  type        = string
  default     = "22_04-lts-gen2"
}

variable "image_version" {
  description = "Versión de la imagen del SO"
  type        = string
  default     = "latest"
}

variable "tags" {
  description = "Tags para aplicar a los recursos de compute"
  type        = map(string)
  default     = {}
}
