# 🚀 Guía de Configuración

Esta guía te ayudará a configurar el proyecto desde cero.

## Prerrequisitos

### Software Requerido

- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) v2.40+
- [Terraform](https://www.terraform.io/downloads) v1.6+
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/) v2.10+
- Git v2.30+
- Cuenta de Azure activa
- Proyecto de Azure DevOps

### Permisos Necesarios

- **Azure**: Contributor en la suscripción
- **Azure DevOps**: Permisos de administrador en el proyecto

## Configuración Paso a Paso

### 1. Crear Service Principal en Azure

El Service Principal permite que Azure DevOps interactúe con Azure.

```bash
az login
az ad sp create-for-rbac --name "terraform-ansible-demo" --role Contributor
```

⚠️ **Importante**: Guarda el output (appId, password, tenant) para Azure DevOps.

---

### 2. Configurar Variables en Azure DevOps

#### Opción A: Variables de Pipeline (Recomendado para demo)

1. Ve a tu proyecto en Azure DevOps
2. Navega a **Pipelines** → Selecciona tu pipeline
3. Click en **Edit** → **Variables** → **New variable**
4. Agrega las siguientes variables:

| Nombre de Variable              | Valor                        | Tipo   | Notas                |
| ------------------------------- | ---------------------------- | ------ | -------------------- |
| `azureServicePrincipalUsername` | `appId` del paso anterior    | Secret | App ID del SP        |
| `azureServicePrincipalPassword` | `password` del paso anterior | Secret | Password del SP      |
| `azureTenant`                   | `tenant` del paso anterior   | Secret | Tenant ID            |
| `azureSubscriptionId`           | Tu Subscription ID           | Normal | ID de tu suscripción |

#### Opción B: Variable Groups (Producción)

1. **Pipelines** → **Library** → **+ Variable group** (`azure-credentials`)
2. Agrega las mismas variables
3. Referencia en YAML: `variables: - group: azure-credentials`

---

### 3. Configurar el Repositorio

```bash
# Clonar el repositorio
git clone https://dev.azure.com/{TU_ORG}/{TU_PROJECT}/_git/iac-lab
cd iac-lab

# Verificar la estructura
tree -L 2
```

**Estructura esperada**:

```
iac-lab/
├── main.tf
├── variables.tf
├── outputs.tf
├── setup_vm.yml
├── azure-pipelines.yml
├── modules/
│   ├── network/
│   ├── security/
│   └── compute/
└── docs/
```

---

### 4. Personalizar Variables (Opcional)

Edita `variables.tf` para cambiar región (`location`), tamaño de VM (`vm_size`), etc.

**Regiones**: `westeurope`, `eastus`, `southeastasia`

---

### 5. Validar Configuración Local (Opcional)

```bash
terraform fmt -recursive && terraform validate
ansible-lint setup_vm.yml
```

---

### 6. Ejecutar el Pipeline

#### Primera Ejecución

1. Haz commit y push de cualquier cambio:

```bash
git add .
git commit -m "Initial setup"
git push origin main
```

2. El pipeline se ejecutará automáticamente
3. Monitorea la ejecución en **Pipelines** → **Runs**

#### Ejecuciones Siguientes

Cada push a `main` ejecuta el pipeline completo:

- ✅ Validaciones (Nivel 1)
- ✅ Tests de integración (Nivel 2)
- ✅ Deploy E2E (Nivel 3)

---

### 7. Verificar el Deployment

Una vez completado el pipeline:

1. Ve a la última ejecución en Azure DevOps
2. En el stage **E2E Tests**, busca el output de **Smoke Tests**
3. Copia la IP pública mostrada en los logs
4. Abre tu navegador: `http://<IP_PUBLICA>`

**Resultado esperado**: Página web con Nginx mostrando "Welcome to IaC Lab!"

---

## Troubleshooting

### Error: "Service Principal authentication failed"

**Síntoma**: Pipeline falla en el step de Terraform init
**Solución**:

1. Verifica que las variables secretas están correctamente configuradas
2. Verifica que el Service Principal tiene permisos de Contributor
3. Ejecuta: `az ad sp show --id {appId}` para verificar que existe

### Error: "VM size not available in location"

**Síntoma**: Terraform plan falla con error de disponibilidad de VM
**Solución**:

1. Cambia la región en `variables.tf`
2. O cambia el tamaño de VM a uno disponible:

```bash
az vm list-sizes --location westeurope --query "[?name=='Standard_B1s']"
```

### Error: "SSH connection timeout"

**Síntoma**: Ansible playbook falla al conectarse a la VM
**Solución**:

1. La VM puede tardar 3-5 minutos en estar lista
2. El pipeline reintenta automáticamente (30 intentos)
3. Verifica que el NSG permite SSH (puerto 22)

### Error: "Terratest failed"

**Síntoma**: Tests de integración fallan
**Solución**:

1. Revisa los logs del job TerratestModules
2. Verifica que tienes suficientes cuotas en Azure
3. Asegúrate de que el cleanup job elimina recursos anteriores

---

## Configuración Avanzada

### Backend Remoto

Crea `backend.tf` con configuración de Azure Storage para el estado de Terraform.

### Múltiples Entornos

Usa archivos `.tfvars` separados (`dev.tfvars`, `prod.tfvars`) con variables específicas.

---

## Costos Estimados

| Recurso             | SKU/Tamaño   | Costo mensual (EUR) |
| ------------------- | ------------ | ------------------- |
| VM Linux            | Standard_B1s | ~8-10 €             |
| IP Pública Estática | Standard     | ~3 €                |
| Disco OS            | 30 GB SSD    | ~1 €                |
| Tráfico de red      | < 5 GB       | ~0 €                |
| **TOTAL**           |              | **~12-14 €/mes**    |

⚠️ **Recordatorio**: Ejecuta `terraform destroy` después de la demo para evitar costos.

---

## Limpieza de Recursos

### Opción 1: Terraform Destroy

```bash
cd iac-lab
terraform destroy -auto-approve
```

### Opción 2: Azure CLI (Más rápido)

```bash
az group delete \
  --name rg-terraform-ansible-demo \
  --yes \
  --no-wait
```

### Opción 3: Portal de Azure

1. Ve a **Resource Groups**
2. Selecciona `rg-terraform-ansible-demo`
3. Click en **Delete resource group**
4. Confirma escribiendo el nombre del grupo

---

## Próximos Pasos

Una vez configurado el proyecto básico:

1. 📖 Lee la [Arquitectura](architecture.md) para entender el diseño
2. 📊 Revisa la [Matriz de Tests](test-matrix.md) para ver los niveles de prueba
3. 🔒 Consulta [README-SECURITY.md](../README-SECURITY.md) para hardening de producción
4. 🧪 Explora los módulos individuales en `modules/*/README.md`

## Soporte

- 📧 Problemas técnicos: Abre un issue en Azure DevOps
- 📚 Documentación: Consulta `docs/`
- 🔍 Logs: Revisa los logs del pipeline en Azure DevOps
