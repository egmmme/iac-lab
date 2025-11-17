# ===================================================================
# OUTPUTS - Valores exportados
# ===================================================================
# Buena práctica: Documentar outputs para reutilización
# ===================================================================

output "vm_public_ip" {
  value       = azurerm_public_ip.demo.ip_address
  description = "IP pública de la VM (para conectar con Ansible)"
}

output "resource_group_name" {
  value       = azurerm_resource_group.demo.name
  description = "Nombre del grupo de recursos creado"
}

output "vm_name" {
  value       = azurerm_linux_virtual_machine.demo.name
  description = "Nombre de la máquina virtual"
}

output "vm_id" {
  value       = azurerm_linux_virtual_machine.demo.id
  description = "ID de la máquina virtual"
}

output "ssh_connection_string" {
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.demo.ip_address}"
  description = "Comando para conectarse por SSH"
}
