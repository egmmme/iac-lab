# Release Notes

## v2.0.1 (2025-11-18)

### Summary

Patch release focusing on CI/CD robustness, documentation clarity, and security improvements following the major v2.0.0 refactor.

### Changes

- CI: Added workflow concurrency controls to prevent overlapping Terraform state operations.
- CI: Introduced `-lock-timeout=5m` for plan/apply/destroy and imports to mitigate state lock contention.
- CI: Generated ephemeral SSH key during destroy to avoid invalid key decode errors.
- CI: Ensured all modular shell scripts are executable and added chmod step in jobs.
- Refactor: Extracted large inline workflow bash blocks into 7 SOLID/KISS modular scripts (`init`, `import-resources`, SSH key management, Ansible inventory & SSH wait, smoke tests).
- Docs: Updated project structure, added detailed scripts README, clarified module responsibilities, improved testing documentation.
- Badges: Added GitHub Actions build status, Terraform version, and tfsec security scan badges.
- Security: Reinforced guidance with README-SECURITY and tfsec strict mode integration.

### Commits Since v2.0.0

- e395456 ci: prevent state lock failures
- 7f066f3 docs: add Terraform version and tfsec security badges
- 0c47275 docs: add GitHub Actions CI status badge
- 5877fe4 ci: fix terraform destroy by generating ephemeral SSH key in cleanup
- d9f7652 docs: update project structure to include scripts and docs folders
- a6f1b55 ci: ensure scripts are executable in runner and repo
- e6dd3e7 Refactor pipeline: Extract inline scripts to modular files (#1)

### Upgrade Notes

No breaking infrastructure changes. Pull latest `main` and continue using existing secrets. New concurrency may cancel overlapping runs—retrigger manually if needed.

### Next Ideas

- Add release automation via workflow_dispatch.
- Introduce cost alert script.
- Optional static code analysis (Checkov) for broader IaC scanning.

---

See previous release notes in tag annotations (v2.0.0).
