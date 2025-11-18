# Security Module

Creates Azure Network Security Group (NSG) with configurable security rules.

## Resources Created

- `azurerm_network_security_group` - NSG with custom rules
- `azurerm_network_security_rule` - Individual security rules (via for_each)

## Key Inputs

- `nsg_name` - NSG resource name
- `security_rules` - List of rule objects with: `name`, `priority`, `direction`, `access`, `protocol`, `source_port_range`, `destination_port_range`, `source_address_prefix`, `destination_address_prefix`

## Key Outputs

- `nsg_id` - Used by compute module to attach NSG to VM NIC
- `security_rules` - Map of configured rules for auditing

## Usage

```hcl
module "security" {
  source = "./modules/security"

  resource_group_name = azurerm_resource_group.demo.name
  location            = azurerm_resource_group.demo.location
  nsg_name            = "nsg-demo"

  security_rules = [
    {
      name                       = "AllowSSH"
      priority                   = 1001
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]
}
```
