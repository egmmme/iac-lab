# 🔒 Consideraciones de Seguridad

## ⚠️ Configuración Actual (Demo/Lab)

Este proyecto está configurado para **entorno de demostración y CI/CD**. Las reglas de seguridad están deliberadamente abiertas para facilitar el testing automatizado.

### Reglas NSG Actuales

```terraform
# ❌ NO USAR EN PRODUCCIÓN
security_rules = [
  {
    name = "AllowSSH"
    source_address_prefix = "*"  # Permite SSH desde CUALQUIER IP
  },
  {
    name = "AllowHTTP"
    source_address_prefix = "*"  # Permite HTTP desde CUALQUIER IP
  }
]
```

## 🛡️ Recomendaciones para Producción

### Opción 1: Restringir por IP (Recomendado para DevOps)

```terraform
# ✅ PRODUCCIÓN: Restringir SSH a IPs corporativas
security_rules = [
  {
    name = "AllowSSH"
    source_address_prefix = "203.0.113.0/24"  # IP de oficina/VPN
    # O múltiples IPs:
    # source_address_prefixes = ["203.0.113.0/24", "198.51.100.0/24"]
  }
]
```

### Opción 2: Azure Bastion (Mejor práctica)

```terraform
# ✅ MEJOR PRÁCTICA: Eliminar SSH público, usar Azure Bastion
# - Sin IP pública en VM
# - Acceso SSH a través de Azure Portal
# - Auditoría completa de accesos
# - Sin exposición a Internet

# NO incluir regla AllowSSH
# Usar Azure Bastion para acceso administrativo
```

### Opción 3: Just-In-Time Access (JIT)

```terraform
# ✅ ALTERNATIVA: Microsoft Defender for Cloud JIT
# - SSH bloqueado por defecto
# - Acceso temporal bajo demanda (1-24h)
# - Requiere aprobación
# - Logs en Azure Security Center
```

## 📋 Checklist de Seguridad Pre-Producción

- [ ] Eliminar `source_address_prefix = "*"` de reglas SSH/RDP
- [ ] Implementar Azure Bastion o JIT Access
- [ ] Habilitar Network Watcher y NSG Flow Logs
- [ ] Configurar Azure Security Center (Defender for Cloud)
- [ ] Implementar Azure Firewall para tráfico saliente
- [ ] Habilitar Microsoft Defender for Servers
- [ ] Configurar alertas de seguridad en Azure Monitor
- [ ] Revisar y aplicar Azure Policy para NSG

## 🧪 Supresión de Alertas tfsec

Para este proyecto de **demo/lab**, las alertas de tfsec están suprimidas con:

```terraform
# tfsec:ignore:azure-network-no-public-ingress
# tfsec:ignore:azure-network-ssh-blocked-from-internet
```

**IMPORTANTE**: En producción, **ELIMINAR** estos comentarios y corregir las vulnerabilidades reales.

## 📚 Referencias

- [Azure Network Security Best Practices](https://learn.microsoft.com/azure/security/fundamentals/network-best-practices)
- [Azure Bastion Documentation](https://learn.microsoft.com/azure/bastion/bastion-overview)
- [Just-In-Time VM Access](https://learn.microsoft.com/azure/defender-for-cloud/just-in-time-access-usage)
- [NSG Security Rules](https://learn.microsoft.com/azure/virtual-network/network-security-groups-overview)

## 🎯 Proceso de Remediación

### Para migrar a producción:

1. **Crear variable para IPs permitidas**:

```terraform
variable "allowed_ssh_ips" {
  description = "IPs permitidas para SSH"
  type        = list(string)
  default     = []  # Vacío = bloquear SSH
}
```

2. **Actualizar regla SSH**:

```terraform
{
  name = "AllowSSH"
  source_address_prefixes = var.allowed_ssh_ips
  # Solo crea regla si hay IPs permitidas
  count = length(var.allowed_ssh_ips) > 0 ? 1 : 0
}
```

3. **Ejecutar tfsec sin ignorar**:

```bash
tfsec . --minimum-severity MEDIUM
```

4. **Validar con Azure Policy**:

```bash
az policy assignment create \
  --name "deny-public-ssh" \
  --policy "Deny SSH from Internet"
```
