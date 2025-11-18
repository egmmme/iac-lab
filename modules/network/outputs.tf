# ===================================================================
# Network Module - Outputs
# ===================================================================

output "vnet_id" {
  description = "Created virtual network ID"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Virtual network name"
  value       = azurerm_virtual_network.main.name
}

output "subnet_id" {
  description = "Created subnet ID"
  value       = azurerm_subnet.main.id
}

output "subnet_name" {
  description = "Subnet name"
  value       = azurerm_subnet.main.name
}

output "public_ip_id" {
  description = "Public IP ID"
  value       = azurerm_public_ip.main.id
}

output "public_ip_address" {
  description = "Assigned public IP address"
  value       = azurerm_public_ip.main.ip_address
}
