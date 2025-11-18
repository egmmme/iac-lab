# 🚀 IaC Lab - Terraform + Ansible en Azure

Proyecto de demostración de infraestructura como código (IaC) usando **Terraform** y **Ansible** con arquitectura modular, testing automatizado y CI/CD en GitHub Actions.

## 🎯 ¿Qué hace este proyecto?

1. **Terraform** crea la infraestructura en Azure (VNet, VM, NSG)
2. **Ansible** configura el servidor (instala Nginx)
3. **GitHub Actions** ejecuta todo automáticamente con testing en 3 niveles

**Resultado**: Servidor web funcional en Azure con validación, testing y deployment automatizados.

## ⚡ Quick Start

```bash
# 1. Clonar repositorio
git clone https://github.com/egmmme/iac-lab.git

# 2. Configurar Service Principal en GitHub Secrets
# Ver guía completa: docs/setup-guide.md

# 3. Push a main para ejecutar el pipeline
git push origin main

# 4. Visitar http://<IP_PUBLICA> cuando termine
```

📖 **Guía detallada**: [docs/setup-guide.md](docs/setup-guide.md)

📖 **Guía detallada**: [docs/setup-guide.md](docs/setup-guide.md)

## 📂 Estructura del Proyecto

```
iac-lab/
├── main.tf                  # Orquestador de módulos Terraform
├── variables.tf             # Variables de configuración
├── outputs.tf               # Outputs del deployment
├── setup_vm.yml             # Playbook de Ansible
├── .github/
│   └── workflows/
│       └── terraform-ansible.yml  # GitHub Actions workflow (3 niveles de testing)
├── modules/                 # Módulos Terraform reutilizables
│   ├── network/             # VNet, Subnet, Public IP
│   ├── security/            # NSG, Security Rules
│   └── compute/             # VM, NIC, SSH Config
├── tests/                   # Tests de integración (Terratest)
│   ├── network_test.go
│   ├── security_test.go
│   └── root_plan_test.go
└── docs/                    # Documentación
    ├── architecture.md      # Arquitectura modular
    ├── setup-guide.md       # Guía de configuración
    ├── test-matrix.md       # Niveles de testing
    └── terraform-vs-ansible.md
```

## 🧪 Testing Automatizado (3 Niveles)

| Nivel | Tipo        | Herramientas                                            | Cuándo                  |
| ----- | ----------- | ------------------------------------------------------- | ----------------------- |
| **1** | Unitarias   | `terraform validate`, `tflint`, `tfsec`, `ansible-lint` | Cada commit             |
| **2** | Integración | Terratest (Go), `terraform plan`                        | Después de validaciones |
| **3** | E2E         | Deploy completo + Smoke tests                           | Solo en `main`          |

📊 **Detalles completos**: [docs/test-matrix.md](docs/test-matrix.md)

## 🏗️ Módulos Terraform

| Módulo       | Responsabilidad     | Recursos                        |
| ------------ | ------------------- | ------------------------------- |
| **network**  | Networking de Azure | VNet, Subnet, Public IP         |
| **security** | Seguridad de red    | NSG, Security Rules (SSH, HTTP) |
| **compute**  | Recursos de cómputo | VM Linux, NIC, Asociaciones     |

📖 Documentación de cada módulo: `modules/*/README.md`  
🏛️ Arquitectura completa: [docs/architecture.md](docs/architecture.md)

## 🔑 Diferencias Terraform vs Ansible

| Aspecto                  | Terraform                    | Ansible                              |
| ------------------------ | ---------------------------- | ------------------------------------ |
| **Propósito**            | Provisionar infraestructura  | Configurar software                  |
| **Sintaxis**             | HCL                          | YAML                                 |
| **Estado**               | Mantiene `terraform.tfstate` | Sin estado                           |
| **Uso en este proyecto** | Crear VMs, redes, NSGs       | Instalar Nginx, configurar servicios |

📖 **Comparativa completa**: [docs/terraform-vs-ansible.md](docs/terraform-vs-ansible.md)

## 🎯 Buenas Prácticas Implementadas

✅ **Modularización**: 3 módulos independientes y reutilizables  
✅ **Versionado IaC**: Todo el código en Git  
✅ **Validación**: Formato, sintaxis, seguridad (tfsec)  
✅ **Testing**: 3 niveles (Unit, Integration, E2E)  
✅ **Seguridad**: Variables secretas, SSH dinámico, escaneo automático  
✅ **CI/CD**: Pipeline automatizado con GitHub Actions  
✅ **Documentación**: README por módulo + guías en `docs/`  
✅ **Cleanup**: Eliminación automática de recursos de test

## 📚 Documentación

| Documento                                               | Contenido                       |
| ------------------------------------------------------- | ------------------------------- |
| [setup-guide.md](docs/setup-guide.md)                   | Configuración paso a paso       |
| [architecture.md](docs/architecture.md)                 | Arquitectura modular y flujo    |
| [test-matrix.md](docs/test-matrix.md)                   | Niveles de testing y validación |
| [terraform-vs-ansible.md](docs/terraform-vs-ansible.md) | Comparativa detallada           |
| [README-SECURITY.md](README-SECURITY.md)                | Seguridad para producción       |

## 🐛 Troubleshooting

### Pipeline falla en Terratest

- Verifica que tienes cuota disponible en Azure
- El cleanup job elimina recursos anteriores automáticamente

### SSH connection timeout

- La VM tarda 3-5 minutos en estar lista
- El pipeline reintenta automáticamente (30 intentos)

### tfsec muestra vulnerabilidades

- Configuración actual es para **demo/lab** (ver [README-SECURITY.md](README-SECURITY.md))
- Para producción: implementar IP restriction, Azure Bastion o JIT Access

📖 **Más soluciones**: [docs/setup-guide.md#troubleshooting](docs/setup-guide.md#troubleshooting)

## 🚀 Próximos Pasos

1. ✅ Pipeline con 3 niveles de testing (completado)
2. 🔄 Agregar módulo de Storage
3. 🔄 Implementar backend remoto (Azure Storage)
4. 🔄 Multi-environment (dev, staging, prod)
5. 🔄 Dashboards de métricas

## 📄 Licencia

MIT License - Proyecto educativo
