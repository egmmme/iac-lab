# 🚀 IaC Lab - Terraform + Ansible on Azure

Infrastructure as Code (IaC) demo using **Terraform** and **Ansible** with modular architecture, automated testing, and CI/CD via GitHub Actions.

## 🎯 What This Project Does

1. **Terraform** provisions Azure infrastructure (VNet, VM, NSG)
2. **Ansible** configures the server (installs Nginx)
3. **GitHub Actions** automates everything with 3-level testing

**Result**: Functional web server on Azure with automated validation, testing, and deployment.

## ⚡ Quick Start

### Prerequisites

- Azure subscription
- GitHub account

### Setup

1. **Create Azure Service Principal**

```bash
az login
az ad sp create-for-rbac --name "terraform-ansible-demo" --role Contributor
```

2. **Configure GitHub Secrets**

Go to: `Repository Settings` → `Secrets and variables` → `Actions` → `New repository secret`

Add these secrets:

| Secret Name             | Value                                |
| ----------------------- | ------------------------------------ |
| `AZURE_CLIENT_ID`       | `appId` from Service Principal       |
| `AZURE_CLIENT_SECRET`   | `password` from Service Principal    |
| `AZURE_TENANT_ID`       | `tenant` from Service Principal      |
| `AZURE_SUBSCRIPTION_ID` | Your Azure subscription ID           |
| `TF_STATE_RG`           | `rg-tfstate-shared` (or your choice) |
| `TF_STATE_STORAGE`      | `tfstateacct123` (globally unique)   |
| `TF_STATE_CONTAINER`    | `tfstate`                            |
| `TF_STATE_KEY`          | `infra-demo.tfstate`                 |

3. **Bootstrap Remote State (Optional)**

```bash
az group create -n rg-tfstate-shared -l "West Europe"
az storage account create --name tfstateacct123 --resource-group rg-tfstate-shared --location "West Europe" --sku Standard_LRS --allow-blob-public-access false
az storage container create --name tfstate --account-name tfstateacct123 --auth-mode login
```

4. **Trigger Pipeline**

```bash
git push origin main
```

5. **Access Your Web Server**

- Find the public IP in GitHub Actions logs
- Visit `http://<PUBLIC_IP>`

## 📂 Project Structure

```
iac-lab/
├── main.tf                          # Terraform orchestrator
├── variables.tf                     # Configuration variables
├── outputs.tf                       # Deployment outputs
├── setup_vm.yml                     # Ansible playbook
├── .github/workflows/
│   └── terraform-ansible.yml        # CI/CD pipeline (3-level testing)
├── modules/                         # Reusable Terraform modules
│   ├── network/                     # VNet, Subnet, Public IP
│   ├── security/                    # NSG, Security Rules
│   └── compute/                     # VM, NIC, SSH Config
└── tests/                           # Integration tests (Terratest)
    ├── network_test.go
    ├── security_test.go
    └── root_plan_test.go
```

## 🧪 Automated Testing (3 Levels)

| Level | Type        | Tools                                                                                    | When           |
| ----- | ----------- | ---------------------------------------------------------------------------------------- | -------------- |
| **1** | Unit        | `terraform validate`, `tflint`, `tfsec`, `ansible-lint`                                  | Every commit   |
| **2** | Integration | Terratest (Go), `tfsec` (strict mode)                                                    | After level 1  |
| **3** | E2E         | Full deploy + Ansible config + Smoke tests (HTTP 200, Nginx headers, content validation) | On `main` only |

📖 Detailed testing documentation: `docs/testing.md`

## 🏗️ Terraform Modules

| Module       | Responsibility    | Resources                       |
| ------------ | ----------------- | ------------------------------- |
| **network**  | Azure networking  | VNet, Subnet, Public IP         |
| **security** | Network security  | NSG, Security Rules (SSH, HTTP) |
| **compute**  | Compute resources | Linux VM, NIC, Associations     |

📖 Module documentation: `modules/*/README.md`

## 🔑 Terraform vs Ansible

| Aspect       | Terraform                     | Ansible                     |
| ------------ | ----------------------------- | --------------------------- |
| **Purpose**  | Provision infrastructure      | Configure software          |
| **Syntax**   | HCL                           | YAML                        |
| **State**    | Maintains `terraform.tfstate` | Stateless                   |
| **Use here** | Create VMs, networks, NSGs    | Install Nginx, configure OS |

## 🎯 Best Practices Implemented

✅ **Modularization**: 3 independent reusable modules  
✅ **IaC Versioning**: All code in Git  
✅ **Validation**: Format, syntax, security (tfsec)  
✅ **Testing**: 3 levels (Unit, Integration, E2E)  
✅ **Security**: Secret variables, dynamic SSH, automated scanning  
✅ **CI/CD**: Automated pipeline with GitHub Actions  
✅ **Remote State**: Azure Storage backend for Terraform state  
✅ **Resource Import**: Automatic import of existing Azure resources  
✅ **Artifact Management**: SSH keys shared between pipeline jobs  
✅ **Cleanup**: Automatic resource deletion after tests

## 🐛 Troubleshooting

### Pipeline fails on Terratest

- Check Azure quota availability
- Cleanup job automatically removes previous resources

### SSH connection timeout

- VM takes 3-5 minutes to be ready
- Pipeline retries automatically (30 attempts)

### tfsec shows vulnerabilities

- Current config is for **demo/lab** (see [README-SECURITY.md](README-SECURITY.md))
- For production: implement IP restriction, Azure Bastion, or JIT Access

## 💰 Estimated Costs

| Resource         | SKU/Size     | Monthly Cost (EUR) |
| ---------------- | ------------ | ------------------ |
| Linux VM         | Standard_B1s | ~8-10 €            |
| Static Public IP | Standard     | ~3 €               |
| OS Disk          | 30 GB SSD    | ~1 €               |
| Network traffic  | < 5 GB       | ~0 €               |
| **TOTAL**        |              | **~12-14 €/month** |

⚠️ **Remember**: Run `terraform destroy` after demo to avoid costs.

## 🧹 Cleanup Resources

```bash
# Option 1: Terraform
terraform destroy -auto-approve

# Option 2: Azure CLI (faster)
az group delete --name rg-terraform-ansible-demo --yes --no-wait
```

## 📄 License

MIT License - Educational project
