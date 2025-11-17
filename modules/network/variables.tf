# ===================================================================
# Network Module - Variables
# ===================================================================

variable "resource_group_name" {
  description = "Nombre del grupo de recursos donde se crearán los recursos de red"
  type        = string
}

variable "location" {
  description = "Ubicación de Azure para los recursos de red"
  type        = string
}

variable "vnet_name" {
  description = "Nombre de la red virtual"
  type        = string
}

variable "address_space" {
  description = "Espacio de direcciones para la VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]

  validation {
    condition     = length(var.address_space) > 0
    error_message = "El espacio de direcciones no puede estar vacío."
  }
}

variable "subnet_name" {
  description = "Nombre de la subred"
  type        = string
}

variable "subnet_prefixes" {
  description = "Prefijos de direcciones para la subred"
  type        = list(string)
  default     = ["10.0.1.0/24"]

  validation {
    condition     = length(var.subnet_prefixes) > 0
    error_message = "Los prefijos de subred no pueden estar vacíos."
  }
}

variable "public_ip_name" {
  description = "Nombre de la IP pública"
  type        = string
}

variable "public_ip_allocation_method" {
  description = "Método de asignación de IP pública (Static o Dynamic)"
  type        = string
  default     = "Static"

  validation {
    condition     = contains(["Static", "Dynamic"], var.public_ip_allocation_method)
    error_message = "El método de asignación debe ser 'Static' o 'Dynamic'."
  }
}

variable "public_ip_sku" {
  description = "SKU de la IP pública (Basic o Standard)"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard"], var.public_ip_sku)
    error_message = "El SKU debe ser 'Basic' o 'Standard'."
  }
}

variable "tags" {
  description = "Tags para aplicar a los recursos de red"
  type        = map(string)
  default     = {}
}
