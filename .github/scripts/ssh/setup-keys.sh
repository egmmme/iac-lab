#!/bin/bash
# ==============================================================================
# SSH Key Setup
# Purpose: Generate SSH keys and configure permissions
# ==============================================================================

set -euo pipefail

readonly SSH_DIR="${SSH_DIR:-$HOME/.ssh}"
readonly KEY_TYPE="${SSH_KEY_TYPE:-rsa}"
readonly KEY_BITS="${SSH_KEY_BITS:-4096}"

echo "🔑 Setting up SSH keys"

# Create SSH directory
mkdir -p "$SSH_DIR"

# Generate SSH key pair
ssh-keygen -t "$KEY_TYPE" -b "$KEY_BITS" -f "$SSH_DIR/id_rsa" -N ""

# Set proper permissions
chmod 600 "$SSH_DIR/id_rsa"
chmod 644 "$SSH_DIR/id_rsa.pub"

echo "✅ SSH keys generated successfully"
echo "Public key: $SSH_DIR/id_rsa.pub"
