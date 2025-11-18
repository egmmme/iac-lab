#!/bin/bash
# ==============================================================================
# Terraform Remote State Initialization
# Purpose: Bootstrap Azure Storage backend and initialize Terraform
# ==============================================================================

set -euo pipefail

# Validate required environment variables
: "${TF_STATE_RG:?TF_STATE_RG not set}"
: "${TF_STATE_STORAGE:?TF_STATE_STORAGE not set}"
: "${TF_STATE_CONTAINER:?TF_STATE_CONTAINER not set}"
: "${TF_STATE_KEY:?TF_STATE_KEY not set}"

readonly LOCATION="${TF_STATE_LOCATION:-West Europe}"

echo "🔐 Bootstrapping remote state resources (idempotent)"

# Create resource group
az group create \
  -n "$TF_STATE_RG" \
  -l "$LOCATION" \
  --tags managedBy=terraform \
  || true

# Create storage account
az storage account create \
  --name "$TF_STATE_STORAGE" \
  --resource-group "$TF_STATE_RG" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --allow-blob-public-access false \
  || true

# Create container
az storage container create \
  --name "$TF_STATE_CONTAINER" \
  --account-name "$TF_STATE_STORAGE" \
  --auth-mode login \
  || true

echo "📦 Initializing Terraform with remote backend"

# Initialize Terraform with backend configuration
terraform init \
  -backend-config="resource_group_name=$TF_STATE_RG" \
  -backend-config="storage_account_name=$TF_STATE_STORAGE" \
  -backend-config="container_name=$TF_STATE_CONTAINER" \
  -backend-config="key=$TF_STATE_KEY"

echo "✅ Terraform initialization complete"
