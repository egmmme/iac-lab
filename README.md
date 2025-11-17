# Comparativa Terraform vs Ansible - Demo en Azure

Este proyecto demuestra las **diferencias entre Terraform y Ansible** en el contexto de infraestructura como código (IaC) y gestión de configuración.

## 🎯 Objetivo

Crear un entorno básico en Azure que muestre:

- **Terraform**: Creación de infraestructura (VM, red, IPs)
- **Ansible**: Configuración de software (instalación de Nginx)
- **Azure DevOps**: Integración CI/CD de ambas herramientas

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

## 🏗️ Arquitectura del Proyecto

```
┌─────────────────────────────────────┐
│   Azure DevOps Pipeline             │
├─────────────────────────────────────┤
│                                     │
│  Stage 1: TERRAFORM                 │
│  ├─ Crear Resource Group            │
│  ├─ Crear VNet + Subnet             │
│  ├─ Crear IP Pública                │
│  ├─ Crear Network Security Group    │
│  └─ Crear VM Linux (Ubuntu)         │
│                                     │
│  Stage 2: ANSIBLE                   │
│  ├─ Conectar por SSH                │
│  ├─ Instalar Nginx                  │
│  ├─ Configurar página web           │
│  └─ Verificar servicio              │
└─────────────────────────────────────┘
```

## 📁 Estructura de Archivos

```
iac-lab/
├── hcl main.tf              # Terraform: Definición de infraestructura
├── setup_vm.yml             # Ansible: Playbook de configuración
├── inventory.ini            # Ansible: Inventario (se genera dinámicamente)
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
   - Crea infraestructura completa
   - Exporta IP pública

2. **Stage Ansible**:
   - Instala Ansible
   - Genera inventario dinámico
   - Espera conexión SSH (hasta 20 intentos)
   - Ejecuta playbook (instala Nginx)
   - Verifica deployment

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
