# ===================================================================
# Security Module - Variables
# ===================================================================

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure location"
  type        = string
}

variable "nsg_name" {
  description = "Network Security Group name"
  type        = string
}

variable "security_rules" {
  description = "List of security rules to apply"
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
    error_message = "Direction must be 'Inbound' or 'Outbound'."
  }

  validation {
    condition = alltrue([
      for rule in var.security_rules :
      contains(["Allow", "Deny"], rule.access)
    ])
    error_message = "Access must be 'Allow' or 'Deny'."
  }

  validation {
    condition = alltrue([
      for rule in var.security_rules :
      rule.priority >= 100 && rule.priority <= 4096
    ])
    error_message = "Priority must be between 100 and 4096."
  }
}

variable "tags" {
  description = "Tags to apply to the NSG"
  type        = map(string)
  default     = {}
}
