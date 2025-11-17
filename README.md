# Azure Infrastructure Automation Lab: Terraform vs Ansible

## Introduction

This lab demonstrates how to automate Azure infrastructure provisioning using Terraform and Ansible. You will:

- Create a resource group with Terraform.
- Configure a virtual machine with Ansible.
- Document differences in syntax, execution, and traceability.
- Integrate both tools in an Azure DevOps pipeline.
- Brief explanation of each file:
  - main.tf: Terraform configuration file. It defines the Azure provider and creates a resource group in Azure.
  - inventory.ini: Ansible inventory file. It lists the target VM(s) for Ansible to manage, including connection details.
  - setup_vm.yml: Ansible playbook. It contains tasks to configure the VM, such as installing NGINX.
  - azure-pipelines.yml: Azure DevOps pipeline definition. It automates the process of running Terraform and Ansible steps in a CI/CD pipeline.

### Prerequisites

- Azure subscription
- Azure CLI installed and authenticated
- Terraform installed ([Download](https://www.terraform.io/downloads.html))
- Ansible installed ([Install Guide](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html))
- Azure DevOps account and project

### 📋 Pipeline Flow:

1. Install dependencies (Azure CLI, Ansible, Terraform)
2. Generate SSH keys
3. Login to Azure
4. Run Terraform (creates VM + networking)
5. Capture VM's public IP
6. Generate inventory.ini with actual IP
7. Wait for VM to boot
8. Run Ansible to install NGINX

### 🚀 What happens when you run the pipeline:

- Delete any existing resources
- Create VM with all networking
- Wait for cloud-init extension to complete (ensures SSH is ready)
- Retry SSH connection up to 20 times with 15-second intervals
- Once connected, run Ansible to install NGINX
- Success! Visit http://<VM_PUBLIC_IP> to see NGINX

### 💰 Cost Note:

- VM size: Standard_B1s (~$7-10/month if running 24/7)
- Remember to delete resources when not needed!

### 🔧 Build and test:

- Use Terraform to provision infrastructure.
- Use Ansible to configure the VM.
- Validate by SSH-ing into the VM and checking NGINX status.
- Check the output logs for the VM's public IP
- Visit http://<IP> to see NGINX running

### 🧹 To clean up resources:
```bash
az group delete --name "lab-resource-group" --yes --no-wait
```

### ✅ SSH Connection Improvements
1. Retry Logic (20 attempts)
Tests SSH connection every 15 seconds
Up to 20 attempts (5 minutes total)
Shows progress for each attempt
Exits with error if all attempts fail
2. Cloud-Init Wait Extension
Added VM extension that waits for cloud-init to complete
Ensures SSH service is fully started before Terraform considers VM ready
Reduces race conditions between VM creation and SSH availability
3. Better Error Handling
Connection timeout set to 10 seconds per attempt
Shows VM power state if connection fails
More informative error messages