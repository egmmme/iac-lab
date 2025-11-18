# Módulo: Network

## Descripción

Módulo Terraform reutilizable para crear infraestructura de red en Azure, incluyendo:

- Virtual Network (VNet)
- Subnet
- Public IP

## Características

- ✅ Nombres descriptivos y parametrizables
- ✅ Validación de variables de entrada
- ✅ Outputs documentados para integración con otros módulos
- ✅ Tags consistentes para gobernanza
- ✅ Configuración flexible de direccionamiento IP

## Variables

| Nombre                        | Tipo         | Descripción                           | Default           | Requerido |
| ----------------------------- | ------------ | ------------------------------------- | ----------------- | --------- |
| `resource_group_name`         | string       | Nombre del grupo de recursos          | -                 | ✅        |
| `location`                    | string       | Ubicación de Azure                    | -                 | ✅        |
| `vnet_name`                   | string       | Nombre de la VNet                     | -                 | ✅        |
| `address_space`               | list(string) | Espacio de direcciones CIDR           | `["10.0.0.0/16"]` | ❌        |
| `subnet_name`                 | string       | Nombre de la subred                   | -                 | ✅        |
| `subnet_prefixes`             | list(string) | Prefijos CIDR de la subred            | `["10.0.1.0/24"]` | ❌        |
| `public_ip_name`              | string       | Nombre de la IP pública               | -                 | ✅        |
| `public_ip_allocation_method` | string       | Método de asignación (Static/Dynamic) | `"Static"`        | ❌        |
| `public_ip_sku`               | string       | SKU de IP pública (Basic/Standard)    | `"Standard"`      | ❌        |
| `tags`                        | map(string)  | Tags para los recursos                | `{}`              | ❌        |

## Outputs

| Nombre              | Descripción                          |
| ------------------- | ------------------------------------ |
| `vnet_id`           | ID de la red virtual                 |
| `vnet_name`         | Nombre de la red virtual             |
| `subnet_id`         | ID de la subred (para conectar NICs) |
| `subnet_name`       | Nombre de la subred                  |
| `public_ip_id`      | ID de la IP pública                  |
| `public_ip_address` | Dirección IP pública asignada        |

## Ejemplo de Uso

```hcl
module "network" {
  source = "./modules/network"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  vnet_name    = "vnet-production"
  subnet_name  = "subnet-web"
  public_ip_name = "pip-web-server"

  address_space    = ["10.0.0.0/16"]
  subnet_prefixes  = ["10.0.1.0/24"]

  public_ip_allocation_method = "Static"
  public_ip_sku              = "Standard"

  tags = {
    environment = "production"
    managed_by  = "terraform"
  }
}

# Usar outputs en otros módulos
output "public_ip" {
  value = module.network.public_ip_address
}
```

## Dependencias

### Recursos Requeridos

- **Resource Group**: Debe existir antes de invocar este módulo

### Módulos que Dependen de Este

- `compute`: Requiere `subnet_id` y `public_ip_id`
- `security`: Puede asociarse a la subnet o NIC

## Validaciones

- ✅ `address_space` no puede estar vacío
- ✅ `subnet_prefixes` no puede estar vacío
- ✅ `public_ip_allocation_method` debe ser "Static" o "Dynamic"
- ✅ `public_ip_sku` debe ser "Basic" o "Standard"

## Buenas Prácticas

1. **Direccionamiento IP**: Planifica el espacio de direcciones para evitar solapamientos
2. **SKU de IP Pública**: Usa "Standard" para alta disponibilidad y zonas de disponibilidad
3. **Nomenclatura**: Usa prefijos descriptivos (vnet-, subnet-, pip-)
4. **Tags**: Siempre incluye tags para gobernanza y costeo

## Pruebas

Para validar este módulo:

```bash
# Validar sintaxis
terraform validate

# Verificar formato
terraform fmt -check

# Simular creación
terraform plan
```

### Testing con Terraform Test (opcional)

Crea un archivo `tests/network.tftest.hcl`:

```hcl
run "validate_network_creation" {
  command = plan

  assert {
    condition     = module.network.vnet_id != ""
    error_message = "VNet ID should not be empty"
  }
}
```

## Versionado

Si compartes este módulo entre equipos, versiona en un repositorio independiente:

```hcl
module "network" {
  source  = "github.com/egmmme/iac-lab//modules/network?ref=v1.0.0"
  # ...
}
```

## Changelog

- **v1.0.0**: Versión inicial con VNet, Subnet, Public IP
