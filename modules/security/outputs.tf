# ===================================================================
# Security Module - Outputs
# ===================================================================

output "nsg_id" {
  description = "Network Security Group ID"
  value       = azurerm_network_security_group.main.id
}

output "nsg_name" {
  description = "Network Security Group name"
  value       = azurerm_network_security_group.main.name
}

output "security_rules" {
  description = "Configured security rules"
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
