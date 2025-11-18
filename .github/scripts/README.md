# GitHub Actions Scripts

This directory contains modular shell scripts used by the Terraform + Ansible CI/CD pipeline.

## Purpose

Following **SOLID**, **Clean Code**, and **KISS** principles, complex inline bash code has been extracted into separate, testable, and maintainable scripts.

## Structure

```
.github/scripts/
├── terraform/
│   ├── init.sh              # Bootstrap remote state & terraform init
│   └── import-resources.sh  # Import existing Azure resources
├── ssh/
│   ├── setup-keys.sh        # Generate SSH key pair
│   └── restore-keys.sh      # Restore SSH keys from artifacts
├── ansible/
│   ├── create-inventory.sh  # Generate Ansible inventory file
│   └── wait-for-ssh.sh      # Wait for VM SSH availability
└── testing/
    └── smoke-tests.sh       # E2E HTTP validation tests
```

## Scripts

### Terraform Scripts

#### `terraform/init.sh`

- **Purpose**: Bootstrap Azure Storage backend and initialize Terraform
- **Environment Variables**:
  - `TF_STATE_RG` (required): Resource group for state storage
  - `TF_STATE_STORAGE` (required): Storage account name
  - `TF_STATE_CONTAINER` (required): Container name
  - `TF_STATE_KEY` (required): State file name
  - `TF_STATE_LOCATION` (optional): Azure region, defaults to "West Europe"

#### `terraform/import-resources.sh`

- **Purpose**: Import 10 pre-existing Azure resources into Terraform state
- **Environment Variables**:
  - `ARM_SUBSCRIPTION_ID` (required): Azure subscription ID
  - `RESOURCE_GROUP` (required): Target resource group
  - `ADMIN_USERNAME` (optional): VM admin user, defaults to "azureuser"
  - `SSH_PUBLIC_KEY_FILE` (optional): SSH key path, defaults to `~/.ssh/id_rsa.pub`

### SSH Scripts

#### `ssh/setup-keys.sh`

- **Purpose**: Generate RSA SSH key pair
- **Environment Variables**:
  - `SSH_DIR` (optional): SSH directory, defaults to `~/.ssh`
  - `SSH_KEY_TYPE` (optional): Key type, defaults to "rsa"
  - `SSH_KEY_BITS` (optional): Key size, defaults to 4096

#### `ssh/restore-keys.sh`

- **Usage**: `./restore-keys.sh <download_dir>`
- **Purpose**: Restore SSH keys from artifact download location
- **Parameters**:
  - `$1`: Download directory, defaults to `/tmp/ssh-keys`

### Ansible Scripts

#### `ansible/create-inventory.sh`

- **Purpose**: Generate dynamic Ansible inventory file
- **Environment Variables**:
  - `VM_IP` (required): Target VM IP address
  - `SSH_USER` (optional): SSH username, defaults to "azureuser"
  - `SSH_KEY` (optional): SSH key path, defaults to `~/.ssh/id_rsa`
  - `INVENTORY_FILE` (optional): Output file, defaults to "inventory.ini"

#### `ansible/wait-for-ssh.sh`

- **Purpose**: Wait for SSH to become available on target VM
- **Environment Variables**:
  - `VM_IP` (required): Target VM IP address
  - `SSH_USER` (optional): SSH username, defaults to "azureuser"
  - `SSH_KEY` (optional): SSH key path, defaults to `~/.ssh/id_rsa`
  - `MAX_RETRIES` (optional): Maximum retry attempts, defaults to 30
  - `INITIAL_WAIT` (optional): Initial wait in seconds, defaults to 60
  - `RETRY_INTERVAL` (optional): Retry interval in seconds, defaults to 10

### Testing Scripts

#### `testing/smoke-tests.sh`

- **Purpose**: E2E validation of deployed web application
- **Environment Variables**:
  - `VM_IP` (required): Target VM IP address
- **Tests**:
  1. HTTP Status 200
  2. Nginx header present
  3. Content validation ("Deployed with Terraform")

## Benefits

### Before Refactoring

- ❌ 500+ lines in workflow file
- ❌ Inline bash scripts difficult to test
- ❌ Duplicated terraform init logic (3 times)
- ❌ Hard to maintain and debug

### After Refactoring

- ✅ ~200 lines in workflow file (60% reduction)
- ✅ Scripts can be tested independently
- ✅ Single source of truth for each operation
- ✅ Clear separation of concerns
- ✅ Reusable across different workflows

## Testing Scripts Locally

All scripts include proper error handling (`set -euo pipefail`) and can be tested locally:

```bash
# Test SSH key generation
./.github/scripts/ssh/setup-keys.sh

# Test smoke tests (requires deployed VM)
export VM_IP="20.123.45.67"
./.github/scripts/testing/smoke-tests.sh

# Test terraform init (requires Azure login)
export TF_STATE_RG="rg-tfstate"
export TF_STATE_STORAGE="tfstateacct123"
export TF_STATE_CONTAINER="tfstate"
export TF_STATE_KEY="demo.tfstate"
./.github/scripts/terraform/init.sh
```

## Principles Applied

### SOLID

- **Single Responsibility**: Each script has one clear purpose
- **Open/Closed**: Scripts are extensible without modifying workflow
- **Dependency Inversion**: Scripts depend on environment variables, not hardcoded values

### Clean Code

- Descriptive names for scripts and functions
- Clear error messages
- Proper logging with emojis for visual scanning
- Exit codes for error handling

### KISS (Keep It Simple, Stupid)

- Small, focused scripts
- Minimal dependencies
- Clear input/output contracts
- No unnecessary complexity
