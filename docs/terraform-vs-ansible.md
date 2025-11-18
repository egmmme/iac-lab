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

✅ **Provisionar infraestructura cloud** (VMs, redes, storage)
✅ **Gestionar recursos de red** (VNets, Load Balancers, Firewalls)
✅ **Configurar servicios cloud** (App Services, Functions, Lambda)
✅ **Orquestar múltiples clouds** (AWS, Azure, GCP)

### Usa Ansible Para:

✅ **Configurar servidores** (instalar software, configurar servicios)
✅ **Gestionar aplicaciones** (despliegues, actualizaciones)
✅ **Automatizar tareas** (backups, mantenimiento, scripts)
✅ **Configuration drift remediation** (asegurar conformidad)

---

## Diferencias Clave

### Creación de Infraestructura

**Terraform** (Declarativo): Define QUÉ debe existir. Gestiona ciclo completo (create, update, destroy).

**Ansible** (Imperativo): Define CÓMO configurar. Solo ejecuta tareas una vez.

### Instalación de Software

**Terraform**: No recomendado. Usa `provisioners` pero no es idempotente.

**Ansible**: Recomendado. Verifica estado antes de actuar (idempotente).

---

## Gestión de Estado

### Terraform State

- Archivo: `terraform.tfstate` (JSON)
- Terraform sabe qué recursos existen, puede calcular diferencias
- Requiere backend remoto para equipos
- Puede contener secrets (sensible)

### Ansible (Sin Estado)

- No mantiene estado persistente
- Simple, sin backend requerido
- Depende de checks en sistemas objetivos
- Difícil detectar drift

---

## Workflow Típico: Terraform + Ansible

1. **Terraform**: Provisiona infraestructura (VMs, red, storage)
2. **Ansible**: Configura servidores (software, aplicaciones)

Ver `azure-pipelines.yml` para ejemplo completo.

---

## Casos de Uso Comunes

| Escenario      | Terraform                 | Ansible                        |
| -------------- | ------------------------- | ------------------------------ |
| **App Web**    | Infra (VNet, App Service) | Deploy código, config env vars |
| **Kubernetes** | Cluster AKS, networking   | Deploy apps (Helm), monitoring |
| **DR**         | Infra región secundaria   | Restaurar backups, verificar   |

---

## Integración en CI/CD

Pipeline típico: Validar → Plan → Apply Terraform → Configurar con Ansible → Tests

Ver `azure-pipelines.yml` en este repo.

---

## Mejores Prácticas

### Terraform

1. ✅ Usa módulos reutilizables
2. ✅ Backend remoto para estado (Azure Storage, Terraform Cloud)
3. ✅ Variables con validación
4. ✅ Outputs documentados

### Ansible

1. ✅ Usa roles reutilizables
2. ✅ Encripta secrets con Ansible Vault
3. ✅ Handlers para reiniciar servicios
4. ✅ Tags para ejecución selectiva

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
