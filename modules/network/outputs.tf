# ===================================================================
# Network Module - Outputs
# ===================================================================

output "vnet_id" {
  description = "ID de la red virtual creada"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Nombre de la red virtual"
  value       = azurerm_virtual_network.main.name
}

output "subnet_id" {
  description = "ID de la subred creada"
  value       = azurerm_subnet.main.id
}

output "subnet_name" {
  description = "Nombre de la subred"
  value       = azurerm_subnet.main.name
}

output "public_ip_id" {
  description = "ID de la IP pública"
  value       = azurerm_public_ip.main.id
}

output "public_ip_address" {
  description = "Dirección IP pública asignada"
  value       = azurerm_public_ip.main.ip_address
}
