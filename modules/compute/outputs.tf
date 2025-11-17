# ===================================================================
# Compute Module - Outputs
# ===================================================================

output "vm_id" {
  description = "ID de la máquina virtual"
  value       = azurerm_linux_virtual_machine.main.id
}

output "vm_name" {
  description = "Nombre de la máquina virtual"
  value       = azurerm_linux_virtual_machine.main.name
}

output "vm_private_ip" {
  description = "Dirección IP privada de la VM"
  value       = azurerm_network_interface.main.private_ip_address
}

output "nic_id" {
  description = "ID de la interfaz de red"
  value       = azurerm_network_interface.main.id
}

output "admin_username" {
  description = "Nombre de usuario administrador de la VM"
  value       = var.admin_username
}
