# Azure Infrastructure Automation Lab: Terraform vs Ansible

## Introduction
This lab demonstrates how to automate Azure infrastructure provisioning using Terraform and Ansible. You will:
- Create a resource group with Terraform.
- Configure a virtual machine with Ansible.
- Document differences in syntax, execution, and traceability.
- Integrate both tools in an Azure DevOps pipeline.
-  Brief explanation of each file:
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


## Build and Test

- Use Terraform to provision infrastructure.
- Use Ansible to configure the VM.
- Validate by SSH-ing into the VM and checking NGINX status.

## Differences: Terraform vs Ansible

| Aspect        | Terraform                                   | Ansible                                  |
|---------------|---------------------------------------------|------------------------------------------|
| Syntax        | Declarative HCL                             | YAML (procedural)                        |
| Execution     | Plans and applies state                     | Executes tasks over SSH                  |
| Traceability  | State file tracks resources                 | Logs per playbook run                    |
| Use Case      | Infrastructure provisioning                 | Configuration management                 |