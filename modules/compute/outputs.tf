# ===================================================================
# Compute Module - Outputs
# ===================================================================

output "vm_id" {
  description = "Virtual machine ID"
  value       = azurerm_linux_virtual_machine.main.id
}

output "vm_name" {
  description = "Virtual machine name"
  value       = azurerm_linux_virtual_machine.main.name
}

output "vm_private_ip" {
  description = "VM private IP address"
  value       = azurerm_network_interface.main.private_ip_address
}

output "nic_id" {
  description = "Network interface ID"
  value       = azurerm_network_interface.main.id
}

output "admin_username" {
  description = "VM administrator username"
  value       = var.admin_username
}
