# ===================================================================
# TERRAFORM - Infraestructura como Código (Arquitectura Modular)
# Propósito: Orquestar módulos reutilizables para crear infraestructura
# ===================================================================
# Buenas prácticas aplicadas:
# ✓ Arquitectura modular (modules/network, modules/security, modules/compute)
# ✓ Versiones fijadas de providers
# ✓ Variables parametrizables (ver variables.tf)
# ✓ Outputs documentados (ver outputs.tf)
# ✓ Tags consistentes para trazabilidad
# ✓ Validación (terraform validate)
# ✓ Formateo (terraform fmt)
# ✓ Módulos documentados con README
# ✓ Separación de responsabilidades (SoC)
# ===================================================================

terraform {
  required_version = ">= 1.6.0"

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
# MÓDULO: NETWORK
# Gestiona VNet, Subnet y Public IP
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
# MÓDULO: SECURITY
# Gestiona NSG y reglas de seguridad
# ===================================================================

module "security" {
  source = "./modules/security"

  resource_group_name = azurerm_resource_group.demo.name
  location            = azurerm_resource_group.demo.location
  nsg_name            = "nsg-${var.environment}"

  security_rules = [
    {
      name                       = "AllowSSH"
      priority                   = 1001
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*" # Buena práctica: restringir a IPs específicas en producción
      destination_address_prefix = "*"
    },
    {
      name                       = "AllowHTTP"
      priority                   = 1002
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]

  tags = var.tags
}

# ===================================================================
# MÓDULO: COMPUTE
# Gestiona VM Linux, NIC y asociación con NSG
# ===================================================================

module "compute" {
  source = "./modules/compute"

  resource_group_name = azurerm_resource_group.demo.name
  location            = azurerm_resource_group.demo.location

  vm_name  = "vm-${var.environment}"
  nic_name = "nic-${var.environment}"
  vm_size  = var.vm_size

  # Dependencias de otros módulos
  subnet_id    = module.network.subnet_id
  public_ip_id = module.network.public_ip_id
  nsg_id       = module.security.nsg_id

  # Configuración de autenticación
  admin_username                  = var.admin_username
  ssh_public_key                  = var.ssh_public_key
  disable_password_authentication = true

  # Configuración de almacenamiento
  os_disk_caching              = "ReadWrite"
  os_disk_storage_account_type = "Standard_LRS"

  # Imagen del SO (Ubuntu 22.04 LTS)
  image_publisher = "Canonical"
  image_offer     = "0001-com-ubuntu-server-jammy"
  image_sku       = "22_04-lts-gen2"
  image_version   = "latest"

  tags = var.tags
}
