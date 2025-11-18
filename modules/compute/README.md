# Compute Module

Creates Linux virtual machines in Azure with network interface, SSH authentication, and disk configuration.

## Resources Created

- `azurerm_network_interface` - NIC with dynamic private IP
- `azurerm_network_interface_security_group_association` - Attaches NSG to NIC
- `azurerm_linux_virtual_machine` - Linux VM with SSH-only authentication

## Key Inputs

- `vm_name`, `nic_name` - Resource names
- `vm_size` - VM SKU (default: `"Standard_B1s"`)
- `subnet_id` - From network module
- `public_ip_id` - From network module (optional)
- `nsg_id` - From security module
- `ssh_public_key` - SSH public key for authentication
- `admin_username` - VM admin user (default: `"azureuser"`)

## Key Outputs

- `vm_id` - Virtual machine ID
- `vm_private_ip` - Private IP address
- `nic_id` - Network interface ID

## Usage

```hcl
module "compute" {
  source = "./modules/compute"

  resource_group_name = azurerm_resource_group.demo.name
  location            = azurerm_resource_group.demo.location

  vm_name  = "vm-demo"
  nic_name = "nic-demo"

  subnet_id      = module.network.subnet_id
  public_ip_id   = module.network.public_ip_id
  nsg_id         = module.security.nsg_id
  ssh_public_key = var.ssh_public_key
}
```
