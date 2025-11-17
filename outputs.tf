# ===================================================================
# OUTPUTS - Valores exportados desde módulos reutilizables
# ===================================================================
# Buena práctica: Documentar outputs y exponer valores de módulos
# ===================================================================

# ===================================================================
# NETWORK OUTPUTS
# ===================================================================

output "vnet_id" {
  description = "ID de la red virtual"
  value       = module.network.vnet_id
}

output "subnet_id" {
  description = "ID de la subred"
  value       = module.network.subnet_id
}

output "vm_public_ip" {
  value       = module.network.public_ip_address
  description = "IP pública de la VM (para conectar con Ansible)"
}

# ===================================================================
# SECURITY OUTPUTS
# ===================================================================

output "nsg_id" {
  description = "ID del Network Security Group"
  value       = module.security.nsg_id
}

output "security_rules" {
  description = "Reglas de seguridad configuradas"
  value       = module.security.security_rules
}

# ===================================================================
# COMPUTE OUTPUTS
# ===================================================================

output "vm_id" {
  value       = module.compute.vm_id
  description = "ID de la máquina virtual"
}

output "vm_name" {
  value       = module.compute.vm_name
  description = "Nombre de la máquina virtual"
}

output "vm_private_ip" {
  description = "Dirección IP privada de la VM"
  value       = module.compute.vm_private_ip
}

# ===================================================================
# RESOURCE GROUP OUTPUTS
# ===================================================================

output "resource_group_name" {
  value       = azurerm_resource_group.demo.name
  description = "Nombre del grupo de recursos creado"
}

output "resource_group_id" {
  description = "ID del grupo de recursos"
  value       = azurerm_resource_group.demo.id
}

# ===================================================================
# HELPER OUTPUTS
# ===================================================================

output "ssh_connection_string" {
  value       = "ssh ${var.admin_username}@${module.network.public_ip_address}"
  description = "Comando para conectarse por SSH"
}
