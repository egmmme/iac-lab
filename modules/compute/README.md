# Módulo: Compute

## Descripción

Módulo Terraform reutilizable para crear máquinas virtuales Linux en Azure con configuración completa de red, autenticación SSH y gestión de discos.

## Características

- ✅ Configuración completa de VM Linux
- ✅ Network Interface con IP privada dinámica
- ✅ Asociación automática con NSG
- ✅ Autenticación SSH segura (sin contraseñas)
- ✅ Gestión flexible de discos del SO
- ✅ Validación de parámetros críticos
- ✅ Soporte para múltiples imágenes de SO

## Variables

### Requeridas

| Nombre                | Tipo               | Descripción                          |
| --------------------- | ------------------ | ------------------------------------ |
| `resource_group_name` | string             | Nombre del grupo de recursos         |
| `location`            | string             | Ubicación de Azure                   |
| `vm_name`             | string             | Nombre de la VM                      |
| `nic_name`            | string             | Nombre de la interfaz de red         |
| `subnet_id`           | string             | ID de la subred (del módulo network) |
| `nsg_id`              | string             | ID del NSG (del módulo security)     |
| `ssh_public_key`      | string (sensitive) | Clave SSH pública                    |

### Opcionales

| Nombre                            | Tipo        | Default                          | Descripción                 |
| --------------------------------- | ----------- | -------------------------------- | --------------------------- |
| `vm_size`                         | string      | `"Standard_B1s"`                 | SKU de la VM                |
| `admin_username`                  | string      | `"azureuser"`                    | Usuario administrador       |
| `public_ip_id`                    | string      | `null`                           | ID de IP pública (opcional) |
| `disable_password_authentication` | bool        | `true`                           | Deshabilitar contraseñas    |
| `os_disk_caching`                 | string      | `"ReadWrite"`                    | Tipo de caché del disco     |
| `os_disk_storage_account_type`    | string      | `"Standard_LRS"`                 | Tipo de almacenamiento      |
| `image_publisher`                 | string      | `"Canonical"`                    | Publisher de la imagen      |
| `image_offer`                     | string      | `"0001-com-ubuntu-server-jammy"` | Offer de la imagen          |
| `image_sku`                       | string      | `"22_04-lts-gen2"`               | SKU de la imagen            |
| `image_version`                   | string      | `"latest"`                       | Versión de la imagen        |
| `tags`                            | map(string) | `{}`                             | Tags para los recursos      |

## Outputs

| Nombre           | Descripción              |
| ---------------- | ------------------------ |
| `vm_id`          | ID de la máquina virtual |
| `vm_name`        | Nombre de la VM          |
| `vm_private_ip`  | Dirección IP privada     |
| `nic_id`         | ID de la interfaz de red |
| `admin_username` | Usuario administrador    |

## Ejemplo de Uso

### Configuración Básica

```hcl
module "compute" {
  source = "./modules/compute"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  vm_name  = "vm-web-server"
  nic_name = "nic-web-server"

  # Dependencias de otros módulos
  subnet_id    = module.network.subnet_id
  public_ip_id = module.network.public_ip_id
  nsg_id       = module.security.nsg_id

  # Configuración SSH
  ssh_public_key = file("~/.ssh/id_rsa.pub")
  admin_username = "azureuser"

  tags = {
    environment = "production"
    role        = "web-server"
  }
}

# Mostrar IP privada
output "vm_private_ip" {
  value = module.compute.vm_private_ip
}
```

### Configuración Avanzada (VM de Alto Rendimiento)

```hcl
module "compute_db" {
  source = "./modules/compute"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  vm_name  = "vm-database"
  vm_size  = "Standard_D4s_v3"  # 4 vCPUs, 16 GB RAM
  nic_name = "nic-database"

  subnet_id = module.network.subnet_id
  nsg_id    = module.security.nsg_id
  # Sin IP pública para seguridad

  ssh_public_key = var.ssh_public_key
  admin_username = "dbadmin"

  # Disco premium para mejor I/O
  os_disk_caching              = "ReadWrite"
  os_disk_storage_account_type = "Premium_LRS"

  # Ubuntu 22.04 LTS
  image_publisher = "Canonical"
  image_offer     = "0001-com-ubuntu-server-jammy"
  image_sku       = "22_04-lts-gen2"
  image_version   = "latest"

  tags = {
    environment = "production"
    role        = "database"
    backup      = "daily"
  }
}
```

### Múltiples VMs con for_each

```hcl
locals {
  vms = {
    web1 = { size = "Standard_B1s", subnet_id = module.network.subnet_id }
    web2 = { size = "Standard_B1s", subnet_id = module.network.subnet_id }
    db   = { size = "Standard_D2s_v3", subnet_id = module.network_private.subnet_id }
  }
}

module "compute" {
  for_each = local.vms
  source   = "./modules/compute"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  vm_name  = "vm-${each.key}"
  nic_name = "nic-${each.key}"
  vm_size  = each.value.size

  subnet_id      = each.value.subnet_id
  nsg_id         = module.security.nsg_id
  ssh_public_key = var.ssh_public_key

  tags = merge(var.common_tags, {
    name = each.key
  })
}
```

## Dependencias

### Módulos Requeridos

1. **network**: Proporciona `subnet_id` y opcionalmente `public_ip_id`
2. **security**: Proporciona `nsg_id`

### Diagrama de Dependencias

```
┌─────────────────┐
│ Resource Group  │
└────────┬────────┘
         │
    ┌────▼─────────────────────────────┐
    │                                  │
┌───▼────────┐              ┌──────────▼──────┐
│  Network   │              │    Security     │
│   Module   │              │     Module      │
│            │              │                 │
│ - VNet     │              │ - NSG           │
│ - Subnet   │──────────┐   │ - Rules         │
│ - Public IP│          │   │                 │
└────────────┘          │   └─────────────────┘
                        │            │
                   ┌────▼────────────▼─────┐
                   │   Compute Module      │
                   │                       │
                   │ - NIC                 │
                   │ - VM                  │
                   │ - SSH Key Config      │
                   └───────────────────────┘
```

## Validaciones

- ✅ `vm_size` debe comenzar con "Standard\_"
- ✅ `admin_username` entre 1 y 64 caracteres
- ✅ `ssh_public_key` debe ser clave SSH válida (ssh-rsa, ssh-ed25519, ecdsa)
- ✅ `os_disk_caching` debe ser None/ReadOnly/ReadWrite
- ✅ `os_disk_storage_account_type` debe ser Standard_LRS/StandardSSD_LRS/Premium_LRS

## Buenas Prácticas

### 🔒 Seguridad

1. **SSH Only**: Mantén `disable_password_authentication = true`
2. **Claves Únicas**: Genera claves SSH específicas por ambiente
3. **Secrets Management**: Usa Azure Key Vault para almacenar claves privadas
4. **Principio de Menor Privilegio**: Conecta VMs de backend a subnets sin IP pública

### 💾 Almacenamiento

| Tipo            | Uso Recomendado          | Costo       | Rendimiento |
| --------------- | ------------------------ | ----------- | ----------- |
| Standard_LRS    | Dev/Test, logs           | 💰 Bajo     | ⚡ Bajo     |
| StandardSSD_LRS | Web servers, apps        | 💰💰 Medio  | ⚡⚡ Medio  |
| Premium_LRS     | Databases, I/O intensivo | 💰💰💰 Alto | ⚡⚡⚡ Alto |

### 📏 Sizing

```hcl
# Dev/Test
vm_size = "Standard_B1s"     # 1 vCPU, 1 GB RAM, ~$8/mes

# Producción Web
vm_size = "Standard_B2s"     # 2 vCPU, 4 GB RAM, ~$30/mes

# Producción Database
vm_size = "Standard_D4s_v3"  # 4 vCPU, 16 GB RAM, ~$150/mes
```

## Imágenes de SO Soportadas

### Ubuntu

```hcl
# Ubuntu 22.04 LTS (recomendado)
image_publisher = "Canonical"
image_offer     = "0001-com-ubuntu-server-jammy"
image_sku       = "22_04-lts-gen2"

# Ubuntu 20.04 LTS
image_offer     = "0001-com-ubuntu-server-focal"
image_sku       = "20_04-lts-gen2"
```

### Red Hat

```hcl
image_publisher = "RedHat"
image_offer     = "RHEL"
image_sku       = "9-lvm-gen2"
```

### Debian

```hcl
image_publisher = "Debian"
image_offer     = "debian-11"
image_sku       = "11-gen2"
```

## Pruebas

### Validación Local

```bash
# Validar módulo
terraform validate

# Ver plan sin ejecutar
terraform plan -target=module.compute

# Verificar formato
terraform fmt -check modules/compute/
```

### Testing con Terratest

```go
// tests/compute_test.go
func TestComputeModule(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../modules/compute",
        Vars: map[string]interface{}{
            "resource_group_name": "test-rg",
            "location": "westeurope",
            "vm_name": "test-vm",
            "ssh_public_key": "ssh-rsa AAAAB3...",
            // ...
        },
    }

    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)

    vmID := terraform.Output(t, terraformOptions, "vm_id")
    assert.Contains(t, vmID, "test-vm")
}
```

### Testing con Terraform Test

```hcl
# tests/compute.tftest.hcl
run "validate_vm_creation" {
  command = plan

  assert {
    condition     = module.compute.vm_id != ""
    error_message = "VM ID should not be empty"
  }

  assert {
    condition     = module.compute.admin_username == "azureuser"
    error_message = "Admin username mismatch"
  }
}
```

## Troubleshooting

### Error: SSH Key Format

```
Error: invalid SSH public key format
```

**Solución**: Verifica que la clave comience con `ssh-rsa`, `ssh-ed25519` o `ecdsa-sha2-nistp256`.

### Error: VM Size Not Available

```
Error: The requested VM size Standard_B1s is not available
```

**Solución**: Verifica disponibilidad con:

```bash
az vm list-skus --location westeurope --size Standard_B --output table
```

### Conexión SSH Falla

```bash
# Verificar NSG permite SSH (puerto 22)
az network nsg rule list --nsg-name <nsg-name> -g <rg-name> --query "[?destinationPortRange=='22']"

# Verificar IP pública asignada
az network public-ip show --name <pip-name> -g <rg-name> --query ipAddress
```

## Versionado

```hcl
module "compute" {
  source = "git::https://dev.azure.com/org/project/_git/terraform-modules//compute?ref=v1.0.0"
  # ...
}
```

## Changelog

- **v1.0.0**: Versión inicial con soporte para Ubuntu, validaciones y NIC configurable
