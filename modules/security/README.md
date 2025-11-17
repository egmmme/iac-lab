# Módulo: Security

## Descripción

Módulo Terraform reutilizable para crear y configurar Network Security Groups (NSG) en Azure con reglas de seguridad parametrizables.

## Características

- ✅ Configuración declarativa de reglas de seguridad
- ✅ Validación automática de prioridades y direcciones
- ✅ Uso de `for_each` para reglas dinámicas
- ✅ Outputs detallados para auditoría
- ✅ Flexible y reutilizable

## Variables

| Nombre                | Tipo         | Descripción                  | Default | Requerido |
| --------------------- | ------------ | ---------------------------- | ------- | --------- |
| `resource_group_name` | string       | Nombre del grupo de recursos | -       | ✅        |
| `location`            | string       | Ubicación de Azure           | -       | ✅        |
| `nsg_name`            | string       | Nombre del NSG               | -       | ✅        |
| `security_rules`      | list(object) | Lista de reglas de seguridad | `[]`    | ❌        |
| `tags`                | map(string)  | Tags para el NSG             | `{}`    | ❌        |

### Estructura de `security_rules`

```hcl
{
  name                       = string  # Nombre de la regla
  priority                   = number  # 100-4096
  direction                  = string  # "Inbound" o "Outbound"
  access                     = string  # "Allow" o "Deny"
  protocol                   = string  # "Tcp", "Udp", "Icmp", "*"
  source_port_range          = string  # Ej: "*", "80", "1024-65535"
  destination_port_range     = string  # Ej: "22", "443"
  source_address_prefix      = string  # CIDR, IP, tag de servicio, "*"
  destination_address_prefix = string  # CIDR, IP, tag de servicio, "*"
}
```

## Outputs

| Nombre           | Descripción                              |
| ---------------- | ---------------------------------------- |
| `nsg_id`         | ID del Network Security Group            |
| `nsg_name`       | Nombre del NSG                           |
| `security_rules` | Mapa de reglas configuradas con detalles |

## Ejemplo de Uso

### Configuración Básica (SSH + HTTP)

```hcl
module "security" {
  source = "./modules/security"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  nsg_name            = "nsg-web-server"

  security_rules = [
    {
      name                       = "AllowSSH"
      priority                   = 1001
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "YOUR_IP/32"  # Restringir a IP específica
      destination_address_prefix = "*"
    },
    {
      name                       = "AllowHTTP"
      priority                   = 1002
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "AllowHTTPS"
      priority                   = 1003
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]

  tags = {
    environment = "production"
    purpose     = "web-server"
  }
}
```

### Configuración Avanzada (VPN + Gestión)

```hcl
module "security_vpn" {
  source = "./modules/security"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  nsg_name            = "nsg-vpn-gateway"

  security_rules = [
    {
      name                       = "AllowVPN"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Udp"
      source_port_range          = "*"
      destination_port_range     = "1194"
      source_address_prefix      = "Internet"
      destination_address_prefix = "VirtualNetwork"
    },
    {
      name                       = "DenyAllInbound"
      priority                   = 4096
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]

  tags = {
    environment = "production"
    managed_by  = "terraform"
  }
}
```

## Dependencias

### Recursos Requeridos

- **Resource Group**: Debe existir antes de invocar este módulo

### Módulos que Dependen de Este

- `compute`: Asocia el NSG a la NIC de la VM mediante `nsg_id`

## Validaciones

- ✅ `direction` debe ser "Inbound" o "Outbound"
- ✅ `access` debe ser "Allow" o "Deny"
- ✅ `priority` debe estar entre 100 y 4096
- ⚠️ Las prioridades deben ser únicas por NSG

## Buenas Prácticas

### 🔒 Seguridad

1. **Principio de Menor Privilegio**: Permite solo el tráfico necesario
2. **IP Específicas**: Evita `source_address_prefix = "*"` para SSH/RDP
3. **Reglas de Denegación**: Usa regla DenyAll con prioridad baja (4096)
4. **Auditoría**: Revisa regularmente las reglas con `security_rules` output

### 📋 Nomenclatura

- **Nombres Descriptivos**: `AllowSSHFromVPN`, `DenyRDPFromInternet`
- **Prioridades Organizadas**:
  - 100-999: Reglas críticas
  - 1000-1999: Reglas de aplicación
  - 2000-2999: Reglas de gestión
  - 3000-4095: Reglas de denegación

### 🏗️ Arquitectura

```
┌─────────────────────┐
│  Internet Traffic   │
└──────────┬──────────┘
           │
    ┌──────▼──────┐
    │     NSG     │  <- Este módulo
    │  Priority   │
    │   Ordered   │
    └──────┬──────┘
           │
    ┌──────▼──────┐
    │   Subnet    │
    │     or      │
    │     NIC     │
    └─────────────┘
```

## Pruebas

### Validación Manual

```bash
# Formateo
terraform fmt -check modules/security/

# Validación
terraform validate

# Plan de prueba
terraform plan -target=module.security
```

### Testing Automatizado (Terratest)

```go
// tests/security_test.go
func TestSecurityModule(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../modules/security",
        Vars: map[string]interface{}{
            "resource_group_name": "test-rg",
            "location": "westeurope",
            "nsg_name": "test-nsg",
            "security_rules": []map[string]interface{}{
                {
                    "name": "AllowSSH",
                    "priority": 1001,
                    // ...
                },
            },
        },
    }

    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)

    nsgID := terraform.Output(t, terraformOptions, "nsg_id")
    assert.NotEmpty(t, nsgID)
}
```

## Troubleshooting

### Error: Prioridad Duplicada

```
Error: A rule with priority 1001 already exists
```

**Solución**: Asegura que cada regla tenga una prioridad única.

### Error: Regla No Aplicada

Verifica que el NSG esté asociado:

- A la subnet: `azurerm_subnet_network_security_group_association`
- A la NIC: `azurerm_network_interface_security_group_association`

## Versionado

```hcl
module "security" {
  source = "git::https://dev.azure.com/org/project/_git/terraform-modules//security?ref=v1.0.0"
  # ...
}
```

## Changelog

- **v1.0.0**: Versión inicial con soporte para reglas dinámicas
