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

Creates a Linux VM (Ubuntu 22.04 LTS) in Azure
Configures networking (VNet, Subnet, Public IP, NSG)
Opens ports 22 (SSH) and 80 (HTTP)
Installs NGINX web server via Ansible
You can access NGINX at http://<VM_PUBLIC_IP>

### 💰 Cost Note:

VM size: Standard_B1s (~$7-10/month if running 24/7)
Remember to delete resources when not needed!

### 🔧 Build and test:

- Use Terraform to provision infrastructure.
- Use Ansible to configure the VM.
- Validate by SSH-ing into the VM and checking NGINX status.
- Check the output logs for the VM's public IP
- Visit http://<IP> to see NGINX running

### 🧹 To clean up resources:

Your pipeline is now complete and ready to deploy! 🎉

## Differences: Terraform vs Ansible

| Aspect       | Terraform                   | Ansible                  |
| ------------ | --------------------------- | ------------------------ |
| Syntax       | Declarative HCL             | YAML (procedural)        |
| Execution    | Plans and applies state     | Executes tasks over SSH  |
| Traceability | State file tracks resources | Logs per playbook run    |
| Use Case     | Infrastructure provisioning | Configuration management |
