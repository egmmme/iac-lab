# ===================================================================
# Security Module - Outputs
# ===================================================================

output "nsg_id" {
  description = "ID del Network Security Group"
  value       = azurerm_network_security_group.main.id
}

output "nsg_name" {
  description = "Nombre del Network Security Group"
  value       = azurerm_network_security_group.main.name
}

output "security_rules" {
  description = "Reglas de seguridad configuradas"
  value = {
    for rule in var.security_rules :
    rule.name => {
      priority  = rule.priority
      direction = rule.direction
      access    = rule.access
      protocol  = rule.protocol
      port      = rule.destination_port_range
    }
  }
}
