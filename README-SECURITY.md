# 🔒 Security Considerations

## ⚠️ Current Configuration (Demo/Lab)

This project is configured for **demo environment and CI/CD**. Security rules are deliberately open to facilitate automated testing.

### Current NSG Rules

```terraform
# ❌ DO NOT USE IN PRODUCTION
security_rules = [
  {
    name = "AllowSSH"
    source_address_prefix = "*"  # Allows SSH from ANY IP
  },
  {
    name = "AllowHTTP"
    source_address_prefix = "*"  # Allows HTTP from ANY IP
  }
]
```

## 🛡️ Production Recommendations

### Option 1: Restrict by IP (Recommended for DevOps)

```terraform
# ✅ PRODUCTION: Restrict SSH to corporate IPs
security_rules = [
  {
    name = "AllowSSH"
    source_address_prefix = "203.0.113.0/24"  # Office/VPN IP
    # Or multiple IPs:
    # source_address_prefixes = ["203.0.113.0/24", "198.51.100.0/24"]
  }
]
```

### Option 2: Azure Bastion (Best Practice)

```terraform
# ✅ BEST PRACTICE: Remove public SSH, use Azure Bastion
# - No public IP on VM
# - SSH access through Azure Portal
# - Complete access auditing
# - No Internet exposure

# DO NOT include AllowSSH rule
# Use Azure Bastion for administrative access
```

### Option 3: Just-In-Time Access (JIT)

```terraform
# ✅ ALTERNATIVE: Microsoft Defender for Cloud JIT
# - SSH blocked by default
# - Temporary access on demand (1-24h)
# - Requires approval
# - Logs in Azure Security Center
```

## 📋 Pre-Production Security Checklist

- [ ] Remove `source_address_prefix = "*"` from SSH/RDP rules
- [ ] Implement Azure Bastion or JIT Access
- [ ] Enable Network Watcher and NSG Flow Logs
- [ ] Configure Azure Security Center (Defender for Cloud)
- [ ] Implement Azure Firewall for outbound traffic
- [ ] Enable Microsoft Defender for Servers
- [ ] Configure security alerts in Azure Monitor
- [ ] Review and apply Azure Policy for NSG

## 🧪 tfsec Alert Suppression

For this **demo/lab** project, tfsec alerts are suppressed with:

```terraform
# tfsec:ignore:azure-network-no-public-ingress
# tfsec:ignore:azure-network-ssh-blocked-from-internet
```

**IMPORTANT**: In production, **REMOVE** these comments and fix the actual vulnerabilities.

## 📚 References

- [Azure Network Security Best Practices](https://learn.microsoft.com/azure/security/fundamentals/network-best-practices)
- [Azure Bastion Documentation](https://learn.microsoft.com/azure/bastion/bastion-overview)
- [Just-In-Time VM Access](https://learn.microsoft.com/azure/defender-for-cloud/just-in-time-access-usage)
- [NSG Security Rules](https://learn.microsoft.com/azure/virtual-network/network-security-groups-overview)

## 🎯 Remediation Process

### To migrate to production:

1. **Create variable for allowed IPs**:

```terraform
variable "allowed_ssh_ips" {
  description = "Allowed IPs for SSH"
  type        = list(string)
  default     = []  # Empty = block SSH
}
```

2. **Update SSH rule**:

```terraform
{
  name = "AllowSSH"
  source_address_prefixes = var.allowed_ssh_ips
  # Only create rule if there are allowed IPs
  count = length(var.allowed_ssh_ips) > 0 ? 1 : 0
}
```

3. **Run tfsec without ignoring**:

```bash
tfsec . --minimum-severity MEDIUM
```

4. **Validate with Azure Policy**:

```bash
az policy assignment create \
  --name "deny-public-ssh" \
  --policy "Deny SSH from Internet"
```
