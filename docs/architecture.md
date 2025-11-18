# 🏗️ Architecture

## Overview

Modular Infrastructure as Code (IaC) architecture using Terraform and Ansible with separation of concerns.

## Architecture Diagram

```
┌─────────────────────────────────────────────┐
│         GitHub Actions Workflow              │
├─────────────────────────────────────────────┤
│                                              │
│  Stage 1: TERRAFORM (Modular Infrastructure) │
│  ┌────────────────────────────────────────┐  │
│  │  main.tf (Orchestrator)                │  │
│  │  ├─ Resource Group                     │  │
│  │  ├─ module "network"                   │  │
│  │  │   ├─ VNet                           │  │
│  │  │   ├─ Subnet                         │  │
│  │  │   └─ Public IP                      │  │
│  │  ├─ module "security"                  │  │
│  │  │   ├─ NSG                            │  │
│  │  │   └─ Security Rules (SSH, HTTP)     │  │
│  │  └─ module "compute"                   │  │
│  │      ├─ Network Interface              │  │
│  │      ├─ NSG Association                │  │
│  │      └─ Linux VM (Ubuntu 22.04)        │  │
│  └────────────────────────────────────────┘  │
│                                              │
│  Stage 2: ANSIBLE (Configuration)            │
│  ├─ Connect via SSH                          │
│  ├─ Install Nginx                            │
│  ├─ Configure web page                       │
│  └─ Verify service                           │
└─────────────────────────────────────────────┘
```

## Terraform Modules

### network (`modules/network/`)

- **Purpose**: Manage Azure networking resources
- **Resources**: VNet, Subnet, Public IP
- **Outputs**: `vnet_id`, `subnet_id`, `public_ip_id`

### security (`modules/security/`)

- **Purpose**: Network security configuration
- **Resources**: NSG, Security Rules
- **Outputs**: `nsg_id`, `security_rules`

### compute (`modules/compute/`)

- **Purpose**: Compute resources and associations
- **Resources**: NIC, NSG Association, Linux VM
- **Outputs**: `vm_id`, `vm_private_ip`, `vm_public_ip`

## Benefits of Modular Architecture

| Benefit                | Description                                         |
| ---------------------- | --------------------------------------------------- |
| ✅ **Reusability**     | Modules can be used across projects                 |
| ✅ **Maintainability** | Isolated changes without affecting other components |
| ✅ **Testing**         | Each module can be tested independently             |
| ✅ **Documentation**   | Each module has its own README                      |
| ✅ **Scalability**     | Easy to add new modules (Storage, Database, etc.)   |

## State Management

- **Terraform State**: Remote backend using Azure Storage
  - Resource Group: Configurable via `TF_STATE_RG` secret
  - Storage Account: Configurable via `TF_STATE_STORAGE` secret
  - Container: Configurable via `TF_STATE_CONTAINER` secret
  - Key: Configurable via `TF_STATE_KEY` secret
  - Enables team collaboration and state locking
  - Automatic bootstrap in pipeline (idempotent)
- **Ansible**: Stateless, idempotent execution
- **Resource Import**: Automatic detection and import of pre-existing Azure resources

## Security

- 🔒 Credentials in GitHub Secrets (8 total: 4 Azure + 4 Terraform state)
- 🔒 Dynamic SSH key generation in pipeline
- 🔒 SSH keys managed as GitHub Actions artifacts (1-day retention)
- 🔒 NSG with restrictive rules (SSH and HTTP only)
- 🔒 Security scanning with `tfsec` on every commit (strict mode in Level 2)
- ⚠️ Current config is for **demo/lab** only (see `README-SECURITY.md` for production hardening)
