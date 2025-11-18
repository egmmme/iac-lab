#!/bin/bash
# ==============================================================================
# SSH Connection Wait
# Purpose: Wait for SSH to become available on target VM
# ==============================================================================

set -euo pipefail

# Validate required parameters
: "${VM_IP:?VM_IP not set}"

readonly SSH_USER="${SSH_USER:-azureuser}"
readonly SSH_KEY="${SSH_KEY:-$HOME/.ssh/id_rsa}"
readonly MAX_RETRIES="${MAX_RETRIES:-30}"
readonly INITIAL_WAIT="${INITIAL_WAIT:-60}"
readonly RETRY_INTERVAL="${RETRY_INTERVAL:-10}"

echo "⏳ Waiting for VM to be ready at $VM_IP"

# Initial wait for VM boot
sleep "$INITIAL_WAIT"

# Retry loop
RETRY_COUNT=0
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
  if ssh -o StrictHostKeyChecking=no \
         -o ConnectTimeout=10 \
         -o BatchMode=yes \
         -i "$SSH_KEY" \
         "$SSH_USER@$VM_IP" \
         "echo 'SSH OK'" 2>/dev/null; then
    echo "✅ SSH available!"
    exit 0
  fi
  
  RETRY_COUNT=$((RETRY_COUNT + 1))
  [ $RETRY_COUNT -lt $MAX_RETRIES ] && sleep "$RETRY_INTERVAL"
done

echo "❌ Could not establish SSH connection after $MAX_RETRIES attempts"
exit 1
