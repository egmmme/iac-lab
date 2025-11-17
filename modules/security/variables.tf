# ===================================================================
# Security Module - Variables
# ===================================================================

variable "resource_group_name" {
  description = "Nombre del grupo de recursos"
  type        = string
}

variable "location" {
  description = "Ubicación de Azure"
  type        = string
}

variable "nsg_name" {
  description = "Nombre del Network Security Group"
  type        = string
}

variable "security_rules" {
  description = "Lista de reglas de seguridad a aplicar"
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = []

  validation {
    condition = alltrue([
      for rule in var.security_rules :
      contains(["Inbound", "Outbound"], rule.direction)
    ])
    error_message = "La dirección debe ser 'Inbound' o 'Outbound'."
  }

  validation {
    condition = alltrue([
      for rule in var.security_rules :
      contains(["Allow", "Deny"], rule.access)
    ])
    error_message = "El acceso debe ser 'Allow' o 'Deny'."
  }

  validation {
    condition = alltrue([
      for rule in var.security_rules :
      rule.priority >= 100 && rule.priority <= 4096
    ])
    error_message = "La prioridad debe estar entre 100 y 4096."
  }
}

variable "tags" {
  description = "Tags para aplicar al NSG"
  type        = map(string)
  default     = {}
}
