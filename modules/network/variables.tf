# ===================================================================
# Network Module - Variables
# ===================================================================

variable "resource_group_name" {
  description = "Resource group name where network resources will be created"
  type        = string
}

variable "location" {
  description = "Azure location for network resources"
  type        = string
}

variable "vnet_name" {
  description = "Virtual network name"
  type        = string
}

variable "address_space" {
  description = "Address space for the VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]

  validation {
    condition     = length(var.address_space) > 0
    error_message = "Address space cannot be empty."
  }
}

variable "subnet_name" {
  description = "Subnet name"
  type        = string
}

variable "subnet_prefixes" {
  description = "Address prefixes for the subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]

  validation {
    condition     = length(var.subnet_prefixes) > 0
    error_message = "Subnet prefixes cannot be empty."
  }
}

variable "public_ip_name" {
  description = "Public IP name"
  type        = string
}

variable "public_ip_allocation_method" {
  description = "Public IP allocation method (Static or Dynamic)"
  type        = string
  default     = "Static"

  validation {
    condition     = contains(["Static", "Dynamic"], var.public_ip_allocation_method)
    error_message = "Allocation method must be 'Static' or 'Dynamic'."
  }
}

variable "public_ip_sku" {
  description = "Public IP SKU (Basic or Standard)"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard"], var.public_ip_sku)
    error_message = "SKU must be 'Basic' or 'Standard'."
  }
}

variable "tags" {
  description = "Tags to apply to network resources"
  type        = map(string)
  default     = {}
}
