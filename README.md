# Comparativa Terraform vs Ansible - Demo en Azure (Arquitectura Modular)

Este proyecto demuestra las **diferencias entre Terraform y Ansible** en el contexto de infraestructura como código (IaC) y gestión de configuración, siguiendo **buenas prácticas de modularización**.

## 🎯 Objetivo

Crear un entorno básico en Azure que muestre:

- **Terraform**: Creación de infraestructura modular (Network, Security, Compute)
- **Ansible**: Configuración de software (instalación de Nginx)
- **Azure DevOps**: Integración CI/CD de ambas herramientas
- **Buenas Prácticas**: Módulos reutilizables, validación, testing, documentación

## 📋 Comparativa Terraform vs Ansible

| Aspecto            | Terraform                              | Ansible                                 |
| ------------------ | -------------------------------------- | --------------------------------------- |
| **Propósito**      | Infraestructura (IaC)                  | Configuración de software               |
| **Sintaxis**       | HCL (HashiCorp Configuration Language) | YAML                                    |
| **Estado**         | Mantiene `terraform.tfstate`           | Sin estado (idempotente)                |
| **Enfoque**        | Declarativo                            | Imperativo/Declarativo híbrido          |
| **Ejecución**      | `terraform apply`                      | `ansible-playbook`                      |
| **Ejemplo de uso** | Crear VM, VNet, Storage                | Instalar paquetes, configurar servicios |
| **Dependencias**   | Cloud providers (Azure, AWS, GCP)      | SSH / WinRM                             |
| **Rollback**       | `terraform destroy`                    | Manual (depende de playbook)            |

## 🏗️ Arquitectura Modular del Proyecto

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

### Ventajas de la Arquitectura Modular

✅ **Reutilización**: Los módulos pueden usarse en múltiples proyectos  
✅ **Mantenibilidad**: Cambios aislados sin afectar otros componentes  
✅ **Testing**: Cada módulo se puede probar independientemente  
✅ **Documentación**: Cada módulo tiene su propio README  
✅ **Versionado**: Módulos se pueden versionar independientemente  
✅ **Separación de responsabilidades**: Network, Security y Compute desacoplados

## 📁 Estructura de Archivos

```
iac-lab/
├── main.tf                  # Terraform: Orquestador de módulos
├── variables.tf             # Variables de configuración
├── outputs.tf               # Outputs exportados desde módulos
├── modules/                 # Módulos reutilizables
│   ├── network/             # Módulo de red (VNet, Subnet, Public IP)
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md        # Documentación del módulo
│   ├── security/            # Módulo de seguridad (NSG, Rules)
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   └── compute/             # Módulo de cómputo (VM, NIC)
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── README.md
├── setup_vm.yml             # Ansible: Playbook de configuración
├── inventory.ini            # Ansible: Inventario (generado dinámicamente)
├── azure-pipelines.yml      # Azure DevOps: Pipeline CI/CD
└── README.md                # Esta documentación
```

## 🚀 Configuración y Ejecución

### Prerrequisitos

1. **Azure Subscription** activa
2. **Azure DevOps** project configurado
3. **Service Principal** con permisos de Contributor

### Paso 1: Crear Service Principal

```bash
# Crear service principal
az ad sp create-for-rbac --name "terraform-ansible-demo" \
  --role Contributor \
  --scopes /subscriptions/{TU_SUBSCRIPTION_ID}

# Output:
# {
#   "appId": "xxx",        → azureServicePrincipalUsername
#   "password": "xxx",     → azureServicePrincipalPassword
#   "tenant": "xxx"        → azureTenant
# }
```

### Paso 2: Configurar Variables en Azure DevOps

En **Pipelines → Library → Variable Groups** o directamente en el pipeline:

| Variable                        | Valor                          | Tipo   |
| ------------------------------- | ------------------------------ | ------ |
| `azureServicePrincipalUsername` | App ID del service principal   | Secret |
| `azureServicePrincipalPassword` | Password del service principal | Secret |
| `azureTenant`                   | Tenant ID                      | Secret |

### Paso 3: Ejecutar el Pipeline

1. Hacer commit y push al repositorio
2. El pipeline se ejecuta automáticamente
3. Revisar logs en Azure DevOps

### Resultado Esperado

Después de la ejecución exitosa:

- ✅ Resource Group creado: `rg-terraform-ansible-demo`
- ✅ VM Linux creada con Ubuntu 22.04
- ✅ Nginx instalado y corriendo
- ✅ Página web personalizada accesible en `http://<IP_PUBLICA>`

## 📝 Diferencias Clave en Código

### Terraform (`hcl main.tf`)

```hcl
# Declarativo: Define QUÉ debe existir
resource "azurerm_linux_virtual_machine" "demo" {
  name     = "vm-demo"
  size     = "Standard_B1s"
  location = "West Europe"
  # ...
}
```

**Características**:

- Estado centralizado (`terraform.tfstate`)
- Plan antes de aplicar (`terraform plan`)
- Idempotente: múltiples `apply` no cambian nada si no hay diferencias
- Maneja el ciclo de vida completo (crear, modificar, destruir)

### Ansible (`setup_vm.yml`)

```yaml
# Imperativo: Define CÓMO configurar
- name: Instalar Nginx
  apt:
    name: nginx
    state: present
```

**Características**:

- Sin estado persistente
- Ejecuta tareas en orden
- Requiere conectividad SSH/WinRM
- Ideal para configuración de software

## 🔄 Workflow del Pipeline

1. **Stage Terraform**:

   - Instala Terraform
   - Genera claves SSH
   - Limpia recursos existentes
   - **Valida sintaxis** (`terraform validate`)
   - Crea infraestructura modular (Network → Security → Compute)
   - Exporta IP pública

2. **Stage Ansible**:
   - Instala Ansible
   - **Descarga claves SSH** desde artefactos del pipeline
   - Genera inventario dinámico
   - Espera conexión SSH (hasta 30 intentos)
   - Ejecuta playbook (instala Nginx)
   - Verifica deployment

## 🎯 Buenas Prácticas Implementadas

### 1. ✅ Versionar IaC con el código de la aplicación

- Todo el código Terraform y Ansible está en el mismo repositorio
- Versionado con Git
- CI/CD integrado en Azure DevOps

### 2. ✅ Separar configuración sensible

- **Variables sensibles**: `ssh_public_key` marcada como `sensitive = true`
- **Secrets en pipeline**: Service Principal credentials en variables secretas
- **`.gitignore`**: Excluye `*.tfstate`, `*.tfvars`, claves privadas

### 3. ✅ Validar sintaxis y seguridad antes de aplicar

```yaml
# En el pipeline:
terraform fmt -check    # Verificar formato
terraform validate      # Validar sintaxis
terraform plan          # Revisar cambios antes de aplicar
```

### 4. ✅ Usar módulos reutilizables

#### Módulos Implementados

| Módulo       | Responsabilidad         | Ubicación           |
| ------------ | ----------------------- | ------------------- |
| **network**  | VNet, Subnet, Public IP | `modules/network/`  |
| **security** | NSG, Security Rules     | `modules/security/` |
| **compute**  | VM, NIC, SSH Config     | `modules/compute/`  |

#### Características de los Módulos

- **Nombres descriptivos**: `modules/network`, `modules/security`, `modules/compute`
- **Documentados**: Cada módulo tiene `README.md` con ejemplos
- **Variables validadas**: Validación en `variables.tf` de cada módulo
- **Outputs documentados**: Outputs con descripciones claras
- **Sin acoplamientos**: Comunicación solo mediante outputs/inputs

#### Ejemplo de Uso de Módulos

```hcl
# main.tf orquesta los módulos
module "network" {
  source = "./modules/network"

  resource_group_name = azurerm_resource_group.demo.name
  location            = azurerm_resource_group.demo.location
  # ...
}

module "compute" {
  source = "./modules/compute"

  # Usa outputs del módulo network
  subnet_id    = module.network.subnet_id
  public_ip_id = module.network.public_ip_id
  # ...
}
```

### 5. ✅ Integrar con CI/CD

- **Pipeline de 2 stages**: Terraform → Ansible
- **Validación automática**: Cada push ejecuta el pipeline
- **Artefactos compartidos**: Claves SSH entre stages
- **Outputs publicados**: IP de VM disponible para Ansible

### 6. ✅ Validaciones en Variables

```hcl
# variables.tf
variable "environment" {
  validation {
    condition     = contains(["dev", "demo", "prod"], var.environment)
    error_message = "Environment debe ser dev, demo o prod."
  }
}

variable "ssh_public_key" {
  validation {
    condition     = can(regex("^ssh-rsa|^ssh-ed25519", var.ssh_public_key))
    error_message = "Debe ser una clave SSH pública válida."
  }
}
```

### 7. ✅ Documentación de Módulos

Cada módulo incluye:

- **README.md** con descripción, variables, outputs, ejemplos
- **Tabla de variables** con tipos, defaults y requisitos
- **Ejemplos de uso** básicos y avanzados
- **Validaciones documentadas**
- **Diagramas de dependencias**
- **Guía de testing** (Terratest, Terraform Test)
- **Troubleshooting** común

Ver documentación completa:

- [Módulo Network](modules/network/README.md)
- [Módulo Security](modules/security/README.md)
- [Módulo Compute](modules/compute/README.md)

### 8. ✅ Testing (Documentado)

Aunque no hay tests automatizados ejecutándose, cada módulo documenta:

- Validación manual con `terraform validate`
- Ejemplos de Terratest (Go)
- Ejemplos de Terraform Test (`.tftest.hcl`)

### 9. ✅ Versionado de Módulos (Preparado)

Los módulos están listos para publicarse en registro externo:

```hcl
# Ejemplo para uso futuro
module "network" {
  source = "git::https://dev.azure.com/org/project/_git/terraform-modules//network?ref=v1.0.0"
  # ...
}
```

## 💰 Costos Estimados

- **VM Standard_B1s**: ~$8-10 USD/mes
- **IP Pública estática**: ~$3 USD/mes
- **Tráfico de red**: Mínimo para demo

**Total estimado**: ~$11-13 USD/mes (si se deja corriendo 24/7)

⚠️ **Importante**: Eliminar recursos después de la demo para evitar costos.

## 🧹 Limpieza de Recursos

```bash
# Opción 1: Terraform
terraform destroy -auto-approve

# Opción 2: Azure CLI (más rápido)
az group delete --name rg-terraform-ansible-demo --yes --no-wait
```

## 📚 Recursos Adicionales

- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Ansible Azure Collection](https://docs.ansible.com/ansible/latest/collections/azure/azcollection/)
- [Azure DevOps Pipelines](https://learn.microsoft.com/azure/devops/pipelines/)

## 🐛 Troubleshooting

### Error: "VM size not available"

Cambiar `location = "West Europe"` en `hcl main.tf` por otra región (ej: `eastus2`).

### Error: "SSH connection failed"

La VM puede tardar 2-3 minutos en estar lista. El pipeline reintenta automáticamente.

### Error: Variables no encontradas

Verificar que las variables secretas estén configuradas en Azure DevOps.

## 📖 Conclusiones

Este proyecto demuestra que:

1. **Terraform** es ideal para **provisionar infraestructura** de forma declarativa
2. **Ansible** es perfecto para **configurar software** una vez la infraestructura existe
3. **Azure DevOps** permite **integrar ambas herramientas** en un pipeline CI/CD unificado
4. La combinación de ambas herramientas proporciona una solución completa de IaC

## 📄 Licencia

MIT License - Proyecto educativo para demostración
