# 📊 Comparativa: Terraform vs Ansible

## Introducción

Terraform y Ansible son dos herramientas fundamentales en el ecosistema DevOps, pero tienen propósitos diferentes y complementarios. Este documento explica cuándo usar cada una.

## Tabla Comparativa

| Aspecto                  | Terraform                               | Ansible                         |
| ------------------------ | --------------------------------------- | ------------------------------- |
| **Propósito Principal**  | Infraestructura como Código (IaC)       | Gestión de Configuración        |
| **Paradigma**            | Declarativo                             | Imperativo/Declarativo híbrido  |
| **Sintaxis**             | HCL (HashiCorp Configuration Language)  | YAML                            |
| **Estado**               | Mantiene estado (`terraform.tfstate`)   | Sin estado (stateless)          |
| **Idempotencia**         | Sí (basado en estado)                   | Sí (basado en checks)           |
| **Ámbito**               | Provisión de infraestructura            | Configuración de sistemas       |
| **Proveedores**          | 1000+ (AWS, Azure, GCP, etc.)           | Módulos específicos + SSH/WinRM |
| **Ejecución**            | `terraform apply`                       | `ansible-playbook`              |
| **Dependencias**         | APIs de cloud providers                 | SSH (Linux) / WinRM (Windows)   |
| **Rollback**             | `terraform destroy` o `terraform apply` | Manual (depende del playbook)   |
| **Testing**              | Terratest, Terraform Test               | Molecule, Ansible Test          |
| **Curva de Aprendizaje** | Media-Alta                              | Baja-Media                      |

## ¿Cuándo Usar Cada Herramienta?

### Usa Terraform Para:

✅ **Provisionar infraestructura cloud**

```hcl
# Crear una VM en Azure
resource "azurerm_linux_virtual_machine" "demo" {
  name                = "vm-demo"
  resource_group_name = azurerm_resource_group.demo.name
  location            = "westeurope"
  size                = "Standard_B1s"
  # ...
}
```

✅ **Gestionar recursos de red**

- VNets, Subnets, Load Balancers
- Security Groups, Firewalls
- DNS, CDN

✅ **Configurar servicios cloud**

- Azure App Service
- Azure Functions
- AWS Lambda
- Google Cloud Run

✅ **Gestionar almacenamiento**

- Azure Storage Accounts
- AWS S3 Buckets
- Google Cloud Storage

✅ **Orquestar múltiples clouds (multi-cloud)**

- Terraform como capa de abstracción
- Mismo código para AWS, Azure, GCP

---

### Usa Ansible Para:

✅ **Configurar servidores**

```yaml
# Instalar y configurar Nginx
- name: Instalar Nginx
  apt:
    name: nginx
    state: present

- name: Copiar configuración
  template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
```

✅ **Gestionar software**

- Instalar paquetes
- Actualizar aplicaciones
- Configurar servicios

✅ **Automatizar tareas de mantenimiento**

- Backups
- Rotación de logs
- Limpieza de disco

✅ **Desplegar aplicaciones**

- Copiar archivos
- Reiniciar servicios
- Ejecutar scripts

✅ **Configuración drift remediation**

- Asegurar que la configuración se mantiene
- Corregir desviaciones

---

## Diferencias Clave en Código

### Ejemplo 1: Crear Infraestructura

**Terraform** (Declarativo - QUÉ debe existir):

```hcl
resource "azurerm_virtual_network" "main" {
  name                = "vnet-demo"
  address_space       = ["10.0.0.0/16"]
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.demo.name
}
```

**Ansible** (Imperativo - CÓMO configurar):

```yaml
- name: Crear VNet en Azure
  azure_rm_virtualnetwork:
    name: vnet-demo
    address_prefixes: "10.0.0.0/16"
    location: westeurope
    resource_group: rg-demo
```

**Diferencia**: Terraform gestiona el ciclo de vida completo (crear, actualizar, destruir). Ansible solo ejecuta la tarea una vez.

---

### Ejemplo 2: Instalar Software

**Terraform** (No recomendado, pero posible):

```hcl
resource "null_resource" "install_nginx" {
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx"
    ]
  }
}
```

❌ **Problema**: Terraform no es idempotente para esta tarea. No sabe si Nginx ya está instalado.

**Ansible** (Recomendado):

```yaml
- name: Instalar Nginx
  apt:
    name: nginx
    state: present
    update_cache: yes
```

✅ **Ventaja**: Ansible verifica si Nginx está instalado antes de intentar instalarlo (idempotente).

---

## Gestión de Estado

### Terraform State

**Archivo**: `terraform.tfstate`

**Contenido**:

```json
{
  "version": 4,
  "terraform_version": "1.6.0",
  "resources": [
    {
      "type": "azurerm_virtual_network",
      "name": "main",
      "attributes": {
        "id": "/subscriptions/.../vnet-demo",
        "name": "vnet-demo",
        "address_space": ["10.0.0.0/16"]
      }
    }
  ]
}
```

**Ventajas**:

- ✅ Terraform sabe qué recursos existen
- ✅ Puede calcular diferencias (plan)
- ✅ Previene creación duplicada

**Desventajas**:

- ⚠️ Requiere backend remoto para equipos
- ⚠️ Conflictos si múltiples usuarios modifican estado
- ⚠️ Sensible (puede contener secrets)

### Ansible (Sin Estado)

**No mantiene estado persistente**

**Ventajas**:

- ✅ Simple de usar
- ✅ No requiere backend
- ✅ Sin conflictos de estado

**Desventajas**:

- ⚠️ No sabe qué configuró previamente
- ⚠️ Depende de checks en el sistema objetivo
- ⚠️ Difícil detectar drift

---

## Workflow Típico: Terraform + Ansible

### 1. Provisión de Infraestructura (Terraform)

```bash
# Planificar cambios
terraform plan

# Aplicar cambios
terraform apply

# Outputs
terraform output vm_public_ip
```

**Resultado**: Infraestructura lista (VM, red, storage)

---

### 2. Configuración de Servidores (Ansible)

```bash
# Generar inventario dinámico
echo "[webservers]" > inventory.ini
echo "$(terraform output -raw vm_public_ip)" >> inventory.ini

# Ejecutar playbook
ansible-playbook -i inventory.ini setup_vm.yml
```

**Resultado**: Software instalado y configurado

---

## Casos de Uso Reales

### Caso 1: Aplicación Web en Azure

**Terraform**:

1. Crear Resource Group
2. Crear VNet y Subnet
3. Crear App Service Plan
4. Crear App Service
5. Configurar DNS

**Ansible**:

1. Desplegar código de aplicación
2. Configurar variables de entorno
3. Reiniciar App Service
4. Verificar health check

---

### Caso 2: Cluster de Kubernetes

**Terraform**:

1. Crear AKS cluster
2. Configurar node pools
3. Crear Storage Class
4. Configurar networking

**Ansible**:

1. Instalar herramientas CLI (kubectl, helm)
2. Desplegar aplicaciones con Helm
3. Configurar monitoring (Prometheus)
4. Setup logging (Fluentd)

---

### Caso 3: Disaster Recovery

**Terraform**:

1. Crear infraestructura en región secundaria
2. Configurar replicación de datos
3. Setup Traffic Manager

**Ansible**:

1. Restaurar backups de configuración
2. Sincronizar archivos
3. Verificar servicios
4. Ejecutar smoke tests

---

## Integración en CI/CD

### Pipeline Típico

```yaml
stages:
  - validate
  - plan
  - apply
  - configure
  - test

# Stage 1: Validar Terraform
terraform_validate:
  script:
    - terraform fmt -check
    - terraform validate

# Stage 2: Plan Terraform
terraform_plan:
  script:
    - terraform plan -out=plan.tfplan

# Stage 3: Aplicar Terraform
terraform_apply:
  script:
    - terraform apply plan.tfplan

# Stage 4: Configurar con Ansible
ansible_configure:
  script:
    - ansible-playbook -i inventory setup.yml

# Stage 5: Smoke Tests
smoke_tests:
  script:
    - curl http://$VM_IP
```

---

## Mejores Prácticas

### Terraform

1. ✅ **Usa módulos reutilizables**

   ```hcl
   module "network" {
     source = "./modules/network"
   }
   ```

2. ✅ **Backend remoto para estado**

   ```hcl
   terraform {
     backend "azurerm" {
       storage_account_name = "tfstate"
       container_name       = "state"
       key                  = "prod.tfstate"
     }
   }
   ```

3. ✅ **Variables con validación**

   ```hcl
   variable "environment" {
     validation {
       condition     = contains(["dev", "prod"], var.environment)
       error_message = "Must be dev or prod."
     }
   }
   ```

4. ✅ **Outputs documentados**
   ```hcl
   output "vm_ip" {
     description = "Public IP of the VM"
     value       = azurerm_public_ip.main.ip_address
   }
   ```

---

### Ansible

1. ✅ **Usa roles reutilizables**

   ```yaml
   roles:
     - common
     - webserver
     - monitoring
   ```

2. ✅ **Variables encriptadas con Vault**

   ```bash
   ansible-vault encrypt secrets.yml
   ```

3. ✅ **Handlers para reiniciar servicios**

   ```yaml
   handlers:
     - name: restart nginx
       service:
         name: nginx
         state: restarted
   ```

4. ✅ **Tags para ejecución selectiva**
   ```yaml
   - name: Instalar Nginx
     apt:
       name: nginx
     tags: [webserver, install]
   ```

---

## Conclusión

**Terraform y Ansible son complementarios, no competidores.**

| Fase del Ciclo          | Herramienta Recomendada |
| ----------------------- | ----------------------- |
| Provisión de infra      | ✅ Terraform            |
| Configuración de OS     | ✅ Ansible              |
| Instalación de software | ✅ Ansible              |
| Gestión de red cloud    | ✅ Terraform            |
| Deployment de apps      | ✅ Ansible              |
| Gestión multi-cloud     | ✅ Terraform            |

**Usa ambas herramientas juntas para obtener lo mejor de cada una.**

---

## Recursos Adicionales

- [Terraform Documentation](https://www.terraform.io/docs)
- [Ansible Documentation](https://docs.ansible.com/)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
