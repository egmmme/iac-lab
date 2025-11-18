# 🏗️ Arquitectura del Proyecto

## Visión General

Este proyecto implementa una arquitectura modular para infraestructura como código (IaC) usando Terraform y Ansible, siguiendo el patrón de separación de responsabilidades.

## Diagrama de Arquitectura

```
┌──────────────────────────────────────────────────────────────┐
│                    Azure DevOps Pipeline                     │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  Stage 1: TERRAFORM (Infraestructura Modular)                │
│  ┌────────────────────────────────────────────────────────┐  │
│  │  main.tf (Orquestador)                                 │  │
│  │  ├─ Resource Group                                     │  │
│  │  ├─ module "network"  ──→ modules/network/             │  │
│  │  │   ├─ VNet                                           │  │
│  │  │   ├─ Subnet                                         │  │
│  │  │   └─ Public IP                                      │  │
│  │  ├─ module "security" ──→ modules/security/            │  │
│  │  │   ├─ NSG                                            │  │
│  │  │   └─ Security Rules (SSH, HTTP)                    │  │
│  │  └─ module "compute"  ──→ modules/compute/             │  │
│  │      ├─ Network Interface                              │  │
│  │      ├─ NSG Association                                │  │
│  │      └─ Linux VM (Ubuntu 22.04)                        │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
│  Stage 2: ANSIBLE (Configuración)                            │
│  ├─ Conectar por SSH                                         │
│  ├─ Instalar Nginx                                           │
│  ├─ Configurar página web                                    │
│  └─ Verificar servicio                                       │
└──────────────────────────────────────────────────────────────┘
```

## Módulos Terraform

### 1. Módulo Network (`modules/network/`)

**Responsabilidad**: Gestionar recursos de red de Azure

**Recursos creados**:

- Virtual Network (VNet)
- Subnet
- Public IP

**Outputs principales**:

- `vnet_id` - ID de la red virtual
- `subnet_id` - ID de la subnet
- `public_ip_id` - ID de la IP pública

[📖 Documentación completa](../modules/network/README.md)

---

### 2. Módulo Security (`modules/security/`)

**Responsabilidad**: Configuración de seguridad de red

**Recursos creados**:

- Network Security Group (NSG)
- Security Rules (SSH, HTTP)

**Outputs principales**:

- `nsg_id` - ID del NSG
- `security_rules` - Mapa de reglas configuradas

[📖 Documentación completa](../modules/security/README.md)

---

### 3. Módulo Compute (`modules/compute/`)

**Responsabilidad**: Recursos de cómputo y asociaciones

**Recursos creados**:

- Network Interface
- NSG Association
- Linux Virtual Machine

**Outputs principales**:

- `vm_id` - ID de la máquina virtual
- `vm_private_ip` - IP privada de la VM
- `vm_public_ip` - IP pública de la VM

[📖 Documentación completa](../modules/compute/README.md)

---

## Ventajas de la Arquitectura Modular

| Ventaja                           | Descripción                                            |
| --------------------------------- | ------------------------------------------------------ |
| ✅ **Reutilización**              | Los módulos pueden usarse en múltiples proyectos       |
| ✅ **Mantenibilidad**             | Cambios aislados sin afectar otros componentes         |
| ✅ **Testing**                    | Cada módulo se puede probar independientemente         |
| ✅ **Documentación**              | Cada módulo tiene su propio README                     |
| ✅ **Versionado**                 | Módulos se pueden versionar independientemente         |
| ✅ **Separación de Responsabil.** | Network, Security y Compute desacoplados               |
| ✅ **Escalabilidad**              | Fácil agregar nuevos módulos (Storage, Database, etc.) |

## Uso de Módulos

Los módulos se invocan desde `main.tf` pasando los outputs de unos a otros:

```hcl
module "network" {
  source = "./modules/network"
  # ... variables
}

module "compute" {
  source = "./modules/compute"
  subnet_id = module.network.subnet_id  # Usa output de network
  # ... más variables
}
```

Ver `main.tf` para el ejemplo completo.

## Gestión de Estado

**Terraform State**:

- Almacenado localmente en `.terraform/terraform.tfstate` (demo)
- En producción: usar backend remoto (Azure Storage, Terraform Cloud)

**Ansible**:

- Sin estado persistente
- Idempotente: ejecutar múltiples veces produce el mismo resultado

## Seguridad

- 🔒 Credenciales en variables secretas de Azure DevOps
- 🔒 SSH keys generadas dinámicamente en el pipeline
- 🔒 NSG con reglas restrictivas (solo SSH y HTTP)
- 🔒 Escaneo de seguridad con `tfsec` en cada commit
- ⚠️ Configuración actual es para **demo/lab** (ver [README-SECURITY.md](../README-SECURITY.md))

## Próximos Pasos de Arquitectura

1. 🔄 Agregar módulo de Storage (Azure Storage Account)
2. 🔄 Agregar módulo de Database (Azure SQL / Cosmos DB)
3. 🔄 Implementar backend remoto para Terraform state
4. 🔄 Agregar Load Balancer para alta disponibilidad
5. 🔄 Implementar múltiples entornos (dev, staging, prod)
