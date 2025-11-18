# ===================================================================
# OUTPUTS - Values exported from reusable modules
# ===================================================================
# Best practice: Document outputs and expose module values
# ===================================================================

# ===================================================================
# NETWORK OUTPUTS
# ===================================================================

output "vnet_id" {
  description = "Virtual network ID"
  value       = module.network.vnet_id
}

output "subnet_id" {
  description = "Subnet ID"
  value       = module.network.subnet_id
}

output "vm_public_ip" {
  value       = module.network.public_ip_address
  description = "VM public IP (for Ansible connection)"
}

# ===================================================================
# SECURITY OUTPUTS
# ===================================================================

output "nsg_id" {
  description = "Network Security Group ID"
  value       = module.security.nsg_id
}

output "security_rules" {
  description = "Configured security rules"
  value       = module.security.security_rules
}

# ===================================================================
# COMPUTE OUTPUTS
# ===================================================================

output "vm_id" {
  value       = module.compute.vm_id
  description = "Virtual machine ID"
}

output "vm_name" {
  value       = module.compute.vm_name
  description = "Virtual machine name"
}

output "vm_private_ip" {
  description = "VM private IP address"
  value       = module.compute.vm_private_ip
}

# ===================================================================
# RESOURCE GROUP OUTPUTS
# ===================================================================

output "resource_group_name" {
  value       = azurerm_resource_group.demo.name
  description = "Created resource group name"
}

output "resource_group_id" {
  description = "Resource group ID"
  value       = azurerm_resource_group.demo.id
}

# ===================================================================
# HELPER OUTPUTS
# ===================================================================

output "ssh_connection_string" {
  value       = "ssh ${var.admin_username}@${module.network.public_ip_address}"
  description = "SSH connection command"
}
