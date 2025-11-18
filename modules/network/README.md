# Network Module

Creates Azure network infrastructure including Virtual Network, Subnet, and Public IP.

## Resources Created

- `azurerm_virtual_network` - Virtual network with configurable address space
- `azurerm_subnet` - Subnet within the VNet
- `azurerm_public_ip` - Public IP address (Static/Dynamic)

## Key Inputs

- `vnet_name`, `subnet_name`, `public_ip_name` - Resource names
- `address_space` - VNet CIDR (default: `["10.0.0.0/16"]`)
- `subnet_prefixes` - Subnet CIDR (default: `["10.0.1.0/24"]`)
- `public_ip_allocation_method` - Static or Dynamic (default: `"Static"`)

## Key Outputs

- `subnet_id` - Used by compute module to attach VMs
- `public_ip_id` - Used by compute module for VM public access
- `public_ip_address` - The assigned public IP

## Usage

```hcl
module "network" {
  source = "./modules/network"

  resource_group_name = azurerm_resource_group.demo.name
  location            = azurerm_resource_group.demo.location
  vnet_name           = "vnet-demo"
  subnet_name         = "subnet-demo"
  public_ip_name      = "pip-demo"
}
```
