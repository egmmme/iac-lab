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
		PlanFilePath: "root.tfplan",
		Vars: map[string]interface{}{
			"resource_group_name": "rg-terratest-root",
			"location":            "westeurope",
			"vm_size":             "Standard_B1s",
			"admin_username":      "azureuser",
			"environment":         "demo",
			"ssh_public_key":      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCpsHJnyOHmXC5bJkw9PAzebRuA+4DQyi6rbjcdY7VD1l7973N985hVWSCsooNlp1u676Nftip/ZUh/Xg9iyD0mt7L9amcfZKcI6qxF5bgdj/++uHX0z61zCSxnKjZyyeflAhwgVdwaB7lnzIrITGXYjX5xyw5C6l7+PfCeFbjGktZk4p+EzVkahWtw9ceg8INPBV+AjfGoPXOq5bQGGyGbqVMp8a9w5LQ9sHy5NoAFnjT39j2Ga510RQzq8qiCNZF5a6uU3oP57iXFVeMbnXuDf+TlIjpExTa+gFGTEPF6klP9VG9K9yPvgZKHPOoekY5jbx8HghlaLCPQAWbO1/Fx terratest@example",
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
