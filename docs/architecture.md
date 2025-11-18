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
  - Container: `tfstate`
  - Key: `infra-demo.tfstate`
  - Enables team collaboration and state locking
- **Ansible**: Stateless, idempotent execution

## Security

- 🔒 Credentials in GitHub Secrets
- 🔒 Dynamic SSH key generation in pipeline
- 🔒 NSG with restrictive rules (SSH and HTTP only)
- 🔒 Security scanning with `tfsec` on every commit
- ⚠️ Current config is for **demo/lab** only
