#!/bin/bash
# ==============================================================================
# Terraform Resource Import
# Purpose: Import existing Azure resources into Terraform state
# ==============================================================================

set -euo pipefail

# Validate required environment variables
: "${ARM_SUBSCRIPTION_ID:?ARM_SUBSCRIPTION_ID not set}"
: "${RESOURCE_GROUP:?RESOURCE_GROUP not set}"

readonly ADMIN_USERNAME="${ADMIN_USERNAME:-azureuser}"
readonly SSH_PUBLIC_KEY_FILE="${SSH_PUBLIC_KEY_FILE:-$HOME/.ssh/id_rsa.pub}"

# Check if SSH key exists
if [[ ! -f "$SSH_PUBLIC_KEY_FILE" ]]; then
  echo "❌ SSH public key not found: $SSH_PUBLIC_KEY_FILE"
  exit 1
fi

readonly SSH_KEY=$(cat "$SSH_PUBLIC_KEY_FILE")

# Common import variables
readonly TF_VARS=(
  -var="admin_username=$ADMIN_USERNAME"
  -var="ssh_public_key=$SSH_KEY"
)

echo "🔍 Checking current Terraform state..."
terraform state list || echo "State is empty"

# ==============================================================================
# Helper function to import resource
# ==============================================================================
import_resource() {
  local resource_name=$1
  local tf_address=$2
  local azure_id=$3
  local check_command=$4

  if terraform state list 2>/dev/null | grep -q "$tf_address"; then
    echo "✅ $resource_name already in state"
    return 0
  fi

  if eval "$check_command" >/dev/null 2>&1; then
    echo "➡️ Importing $resource_name"
    terraform import "${TF_VARS[@]}" "$tf_address" "$azure_id" || echo "⚠️ Import failed for $resource_name"
  fi
}

# ==============================================================================
# Import all resources
# ==============================================================================

# Resource Group
import_resource \
  "Resource Group" \
  "azurerm_resource_group.demo" \
  "/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP" \
  "az group show -n $RESOURCE_GROUP"

# VNet
import_resource \
  "Virtual Network" \
  "module.network.azurerm_virtual_network.main" \
  "/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Network/virtualNetworks/vnet-demo" \
  "az network vnet show --ids '/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Network/virtualNetworks/vnet-demo'"

# Subnet
import_resource \
  "Subnet" \
  "module.network.azurerm_subnet.main" \
  "/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Network/virtualNetworks/vnet-demo/subnets/subnet-demo" \
  "az network vnet subnet show --ids '/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Network/virtualNetworks/vnet-demo/subnets/subnet-demo'"

# Public IP
import_resource \
  "Public IP" \
  "module.network.azurerm_public_ip.main" \
  "/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Network/publicIPAddresses/pip-demo" \
  "az network public-ip show --ids '/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Network/publicIPAddresses/pip-demo'"

# NSG
import_resource \
  "Network Security Group" \
  "module.security.azurerm_network_security_group.main" \
  "/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Network/networkSecurityGroups/nsg-demo" \
  "az network nsg show --ids '/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Network/networkSecurityGroups/nsg-demo'"

# NSG Rules
import_resource \
  "SSH Rule" \
  'module.security.azurerm_network_security_rule.rules["AllowSSH"]' \
  "/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Network/networkSecurityGroups/nsg-demo/securityRules/AllowSSH" \
  "az network nsg rule show --ids '/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Network/networkSecurityGroups/nsg-demo/securityRules/AllowSSH'"

import_resource \
  "HTTP Rule" \
  'module.security.azurerm_network_security_rule.rules["AllowHTTP"]' \
  "/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Network/networkSecurityGroups/nsg-demo/securityRules/AllowHTTP" \
  "az network nsg rule show --ids '/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Network/networkSecurityGroups/nsg-demo/securityRules/AllowHTTP'"

# Network Interface
import_resource \
  "Network Interface" \
  "module.compute.azurerm_network_interface.main" \
  "/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Network/networkInterfaces/nic-demo" \
  "az network nic show --ids '/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Network/networkInterfaces/nic-demo'"

# NIC-NSG Association
import_resource \
  "NIC-NSG Association" \
  "module.compute.azurerm_network_interface_security_group_association.main" \
  "/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Network/networkInterfaces/nic-demo|/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Network/networkSecurityGroups/nsg-demo" \
  "az network nic show --ids '/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Network/networkInterfaces/nic-demo'"

# Virtual Machine
import_resource \
  "Virtual Machine" \
  "module.compute.azurerm_linux_virtual_machine.main" \
  "/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Compute/virtualMachines/vm-demo" \
  "az vm show --ids '/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Compute/virtualMachines/vm-demo'"

echo ""
echo "📋 Final state list:"
terraform state list || echo "No resources in state"
echo "✅ Resource import complete"
