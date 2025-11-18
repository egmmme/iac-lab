#!/bin/bash
# ==============================================================================
# Ansible Inventory Creation
# Purpose: Generate dynamic Ansible inventory file
# ==============================================================================

set -euo pipefail

# Validate required parameters
: "${VM_IP:?VM_IP not set}"

readonly SSH_USER="${SSH_USER:-azureuser}"
readonly SSH_KEY="${SSH_KEY:-$HOME/.ssh/id_rsa}"
readonly INVENTORY_FILE="${INVENTORY_FILE:-inventory.ini}"

echo "📝 Creating Ansible inventory for $VM_IP"

cat > "$INVENTORY_FILE" <<EOF
[webservers]
$VM_IP ansible_user=$SSH_USER ansible_ssh_private_key_file=$SSH_KEY ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOF

echo "✅ Inventory created: $INVENTORY_FILE"
cat "$INVENTORY_FILE"
