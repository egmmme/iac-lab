# ===================================================================
# VARIABLES - Parameterized configuration
# ===================================================================
# Best practice: Separate variables in dedicated file
# ===================================================================

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
  sensitive   = true
}

variable "resource_group_name" {
  description = "Azure resource group name"
  type        = string
  default     = "rg-terraform-ansible-demo"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "West Europe"
}

variable "vm_size" {
  description = "VM size"
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "VM administrator username"
  type        = string
  default     = "azureuser"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "demo"

  validation {
    condition     = contains(["dev", "demo", "prod"], var.environment)
    error_message = "Environment must be: dev, demo, or prod"
  }
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    project     = "terraform-ansible-demo"
    managedBy   = "terraform"
    environment = "demo"
  }
}
