#!/bin/bash
# ==============================================================================
# SSH Key Restoration
# Purpose: Restore SSH keys from artifact download location
# ==============================================================================

set -euo pipefail

readonly DOWNLOAD_DIR="${1:-/tmp/ssh-keys}"
readonly SSH_DIR="$HOME/.ssh"

echo "🔑 Restoring SSH keys from $DOWNLOAD_DIR"

# Create SSH directory
mkdir -p "$SSH_DIR"

# Copy keys
cp "$DOWNLOAD_DIR/id_rsa" "$SSH_DIR/id_rsa"
cp "$DOWNLOAD_DIR/id_rsa.pub" "$SSH_DIR/id_rsa.pub"

# Set proper permissions
chmod 600 "$SSH_DIR/id_rsa"
chmod 644 "$SSH_DIR/id_rsa.pub"

echo "✅ SSH keys restored successfully"
