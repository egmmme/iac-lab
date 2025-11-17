# ===================================================================
# VARIABLES - Configuración parametrizable
# ===================================================================
# Buena práctica: Separar variables en archivo dedicado
# ===================================================================

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
  sensitive   = true
}

variable "resource_group_name" {
  description = "Nombre del grupo de recursos"
  type        = string
  default     = "rg-terraform-ansible-demo"
}

variable "location" {
  description = "Región de Azure para los recursos"
  type        = string
  default     = "West Europe"
}

variable "vm_size" {
  description = "Tamaño de la VM"
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Usuario administrador de la VM"
  type        = string
  default     = "azureuser"
}

variable "environment" {
  description = "Ambiente de despliegue"
  type        = string
  default     = "demo"

  validation {
    condition     = contains(["dev", "demo", "prod"], var.environment)
    error_message = "Environment debe ser: dev, demo o prod"
  }
}

variable "tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
  default = {
    proyecto    = "terraform-ansible-demo"
    managedBy   = "terraform"
    environment = "demo"
  }
}
