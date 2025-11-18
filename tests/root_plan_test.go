package tests

import (
	"testing"

	terratest_terraform "github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// Integration-like plan test at root. Requires Azure creds via ARM_* env vars.
func TestRootPlan(t *testing.T) {
	terraformOptions := &terratest_terraform.Options{
		TerraformDir: "..",
		Vars: map[string]interface{}{
			"resource_group_name": "rg-terratest-root",
			"location":            "westeurope",
			"vm_size":             "Standard_B1s",
			"admin_username":      "azureuser",
			"environment":         "demo",
			"ssh_public_key":      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJmOCK-demo-key-not-used-for-apply== terratest@example",
			"tags": map[string]string{
				"project":   "iac-lab",
				"managedBy": "terraform",
				"env":       "demo",
			},
		},
	}

	plan := terratest_terraform.InitAndPlanAndShowWithStruct(t, terraformOptions)
	
	// Fixed: ResourceChangesMap is directly on plan struct, not in RawPlan
	assert.NotNil(t, plan.ResourceChangesMap, "plan should not be nil")
	assert.Greater(t, len(plan.ResourceChangesMap), 0, "root plan should have resource changes")
}
