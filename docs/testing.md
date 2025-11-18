# 🧪 Test Matrix

## Testing Strategy

3-level automated testing ensuring code quality, security, and functionality before production deployment.

## Test Levels

### Level 1: Unit Tests

**Purpose**: Validate individual module logic and variables in isolation

**Tools**:

- `terraform fmt -check` - Code formatting
- `terraform validate` - Syntax validation
- `tflint` - Terraform linting
- `tfsec` - Security scanning
- `ansible-lint` - Ansible playbook validation

**Success Criteria**:

- ✅ All validations pass without errors
- ✅ No security vulnerabilities detected
- ✅ Code follows best practices

**Trigger**: Every commit or PR

---

### Level 2: Integration Tests

**Purpose**: Verify multiple modules interact correctly

**Tools**:

- **Terratest** - Module testing with `terraform plan`
  - `network_test.go` - Validate network module
  - `security_test.go` - Validate security module
  - `root_plan_test.go` - Validate integrated stack (skipped - covered by E2E)
- **Terraform Plan** - Generate execution plan

**Success Criteria**:

- ✅ All Terratest tests pass
- ✅ Terraform plan generated without errors
- ✅ Expected outputs are present
- ✅ Test resources automatically cleaned up

**Trigger**: After Level 1 passes

---

### Level 3: E2E Tests

**Purpose**: Full deployment in isolated environment with functional verification

**Actions**:

1. **Deploy Infrastructure**
   - Automatic import of existing Azure resources (if pre-created)
   - `terraform apply` - Deploy complete stack
   - Capture outputs (VM public IP)
2. **Configure Services**
   - SSH keys shared via GitHub Actions artifacts
   - Run Ansible playbook (`setup_vm.yml`)
   - Install and configure Nginx with custom page
3. **Smoke Tests**
   - ✅ HTTP Status 200
   - ✅ Nginx headers present
   - ✅ Expected content on web page ("Deployed with Terraform")

**Success Criteria**:

- ✅ Infrastructure deployed without errors
- ✅ All resources imported if they already exist
- ✅ Services configured correctly via Ansible
- ✅ All smoke tests pass (HTTP 200, Nginx headers, content: "Deployed with Terraform")
- ✅ Application accessible from Internet

**Trigger**: Only on `main` branch after Level 2 passes

---

## Pipeline Flow

```
Commit/PR → Level 1: Unit → Level 2: Integration → Level 3: E2E → Success
              ↓ fail           ↓ fail                ↓ fail
            ❌ Stop          ❌ Stop               ❌ Stop
```

## Summary

| Phase       | Actions                           | Trigger       | Duration   |
| ----------- | --------------------------------- | ------------- | ---------- |
| **Pre-PR**  | Syntax, linting                   | Every commit  | ~3-5 min   |
| **In PR**   | Plan, integration tests, security | PR open       | ~10-15 min |
| **On main** | Deploy, E2E, smoke tests          | Merge to main | ~20-30 min |

## Best Practices

### ✅ Security

- Secrets in GitHub Secrets (not hardcoded)
- SSH keys managed as pipeline artifacts
- Service Principal credentials in secret variables

### ✅ Cost Optimization

- Automatic cleanup job after Terratest
- Asynchronous deletion of test resource groups
- Orphaned resource detection and removal

### ✅ Automation

- 100% automated pipeline (3 levels)
- Automatic SSH key generation
- Dynamic Ansible inventory
- Automated smoke tests with multiple validations

## Quality Metrics

| Metric          | Target          | Current Status        |
| --------------- | --------------- | --------------------- |
| Test coverage   | >80% of modules | ✅ 100% (3/3 modules) |
| Pipeline time   | <30 min total   | ✅ ~25 min            |
| Success rate    | >95% on main    | 🟡 Monitor            |
| Vulnerabilities | 0 critical/high | ✅ 0 detected         |
