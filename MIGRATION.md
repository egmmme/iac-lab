# 🚀 Migración a GitHub Completada

## ✅ Estado de la Migración

Este repositorio ha sido migrado exitosamente de **Azure DevOps** a **GitHub**.

### Lo que se ha migrado:

- ✅ **Código fuente completo**: Todo el historial de commits
- ✅ **Ramas**: `main`, `feature/reusable-modules`
- ✅ **Tags**: `1.0.0`, `1.1.0`
- ✅ **CI/CD**: Pipeline migrado a GitHub Actions
- ✅ **Documentación**: Todas las URLs actualizadas

### Configuración de Remotes

```bash
# Remote principal (GitHub)
origin → https://github.com/egmmme/iac-lab.git

# Backup (Azure DevOps)
azure-devops → https://dev.azure.com/egarciamadruga/iac-lab/_git/iac-lab
```

## 🔧 Próximos Pasos

### 1. Configurar GitHub Secrets (REQUERIDO)

Para que el workflow de GitHub Actions funcione, debes configurar los secrets:

1. Ve a: https://github.com/egmmme/iac-lab/settings/secrets/actions
2. Crea estos 4 secrets:
   - `AZURE_CLIENT_ID` → App ID del Service Principal
   - `AZURE_CLIENT_SECRET` → Password del Service Principal
   - `AZURE_TENANT_ID` → Tenant ID de Azure
   - `AZURE_SUBSCRIPTION_ID` → ID de tu suscripción de Azure

📚 **Guía completa**: Ver `docs/setup-guide.md` → Paso 2

### 2. Primera Ejecución del Workflow

Después de configurar los secrets:

```bash
# El workflow ya se ejecutará automáticamente en cada push a main
# O ejecuta manualmente desde:
# https://github.com/egmmme/iac-lab/actions
```

### 3. Verificar el Workflow

1. Ve a: https://github.com/egmmme/iac-lab/actions
2. Verifica que el workflow **Terraform & Ansible CI/CD** aparezca
3. Si hay errores, revisa que los secrets estén correctamente configurados

## 📋 Comparación: Azure DevOps vs GitHub Actions

| Característica               | Azure DevOps                    | GitHub Actions                             |
| ---------------------------- | ------------------------------- | ------------------------------------------ |
| **Archivo de configuración** | `azure-pipelines.yml`           | `.github/workflows/terraform-ansible.yml`  |
| **Ubicación de secrets**     | Pipeline Variables              | Settings → Secrets and variables → Actions |
| **URL del pipeline**         | Azure DevOps → Pipelines → Runs | https://github.com/egmmme/iac-lab/actions  |
| **Trigger**                  | Push a main                     | Push a main + Pull Requests + Manual       |

## 🗑️ Qué hacer con Azure DevOps

### Opción A: Mantener como Backup (Recomendado)

El remote `azure-devops` está configurado como backup. Puedes sincronizarlo ocasionalmente:

```bash
# Sincronizar cambios de GitHub a Azure DevOps
git push azure-devops main --all
git push azure-devops --tags
```

### Opción B: Archivar o Eliminar

Si ya no necesitas Azure DevOps:

1. **Archivar el proyecto**: Azure DevOps → Project Settings → Overview → Archive
2. **O eliminar el remote local**:
   ```bash
   git remote remove azure-devops
   ```

## 📁 Archivos Relacionados con la Migración

- `.github/workflows/terraform-ansible.yml` → Workflow de GitHub Actions (NUEVO)
- `azure-pipelines.yml` → Pipeline de Azure DevOps (CONSERVADO para referencia)
- `docs/setup-guide.md` → Guía actualizada con instrucciones de GitHub

## 🔗 Enlaces Importantes

- **Repositorio GitHub**: https://github.com/egmmme/iac-lab
- **GitHub Actions**: https://github.com/egmmme/iac-lab/actions
- **Issues**: https://github.com/egmmme/iac-lab/issues
- **Documentación**: `docs/`

---

**Fecha de migración**: 2025
**Commit de migración**: `42bd6e2`
