# ===================================================================
# TERRAFORM - Infrastructure as Code (Modular Architecture)
# Purpose: Orchestrate reusable modules to create infrastructure
# ===================================================================
# Best practices applied:
# ✓ Modular architecture (modules/network, modules/security, modules/compute)
# ✓ Pinned provider versions
# ✓ Parameterized variables (see variables.tf)
# ✓ Documented outputs (see outputs.tf)
# ✓ Consistent tags for traceability
# ✓ Validation (terraform validate)
# ✓ Formatting (terraform fmt)
# ✓ Modules documented with README
# ✓ Separation of concerns (SoC)
# ===================================================================

terraform {
  required_version = ">= 1.6.0"

  # Remote backend for shared state (configure via -backend-config flags in CI)
  backend "azurerm" {}

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# ===================================================================
# RESOURCE GROUP
# ===================================================================

resource "azurerm_resource_group" "demo" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# ===================================================================
# MODULE: NETWORK
# Manages VNet, Subnet, and Public IP
# ===================================================================

module "network" {
  source = "./modules/network"

  resource_group_name = azurerm_resource_group.demo.name
  location            = azurerm_resource_group.demo.location

  vnet_name      = "vnet-${var.environment}"
  subnet_name    = "subnet-${var.environment}"
  public_ip_name = "pip-${var.environment}"

  address_space   = ["10.0.0.0/16"]
  subnet_prefixes = ["10.0.1.0/24"]

  public_ip_allocation_method = "Static"
  public_ip_sku               = "Standard"

  tags = var.tags
}

# ===================================================================
# MODULE: SECURITY
# Manages NSG and security rules
# ===================================================================

module "security" {
  source = "./modules/security"

  resource_group_name = azurerm_resource_group.demo.name
  location            = azurerm_resource_group.demo.location
  nsg_name            = "nsg-${var.environment}"

  security_rules = [
    {
      name                   = "AllowSSH"
      priority               = 1001
      direction              = "Inbound"
      access                 = "Allow"
      protocol               = "Tcp"
      source_port_range      = "*"
      destination_port_range = "22"
      # ⚠️ DEMO/LAB ONLY: source_address_prefix = "*" allows access from any IP
      # 🔒 PRODUCTION: Change to specific IP (e.g., "203.0.113.0/24") or use Azure Bastion
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                   = "AllowHTTP"
      priority               = 1002
      direction              = "Inbound"
      access                 = "Allow"
      protocol               = "Tcp"
      source_port_range      = "*"
      destination_port_range = "80"
      # ℹ️ Public HTTP is acceptable for web servers (port 80)
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]

  tags = var.tags
}

# ===================================================================
# MODULE: COMPUTE
# Manages Linux VM, NIC, and NSG association
# ===================================================================

module "compute" {
  source = "./modules/compute"

  resource_group_name = azurerm_resource_group.demo.name
  location            = azurerm_resource_group.demo.location

  vm_name  = "vm-${var.environment}"
  nic_name = "nic-${var.environment}"
  vm_size  = var.vm_size

  # Dependencies from other modules
  subnet_id    = module.network.subnet_id
  public_ip_id = module.network.public_ip_id
  nsg_id       = module.security.nsg_id

  # Authentication configuration
  admin_username                  = var.admin_username
  ssh_public_key                  = var.ssh_public_key
  disable_password_authentication = true

  # Storage configuration
  os_disk_caching              = "ReadWrite"
  os_disk_storage_account_type = "Standard_LRS"

  # OS image (Ubuntu 22.04 LTS)
  image_publisher = "Canonical"
  image_offer     = "0001-com-ubuntu-server-jammy"
  image_sku       = "22_04-lts-gen2"
  image_version   = "latest"

  tags = var.tags
}
