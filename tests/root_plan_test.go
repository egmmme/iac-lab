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
			"ssh_public_key":      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7IQnFX+dGCuK1c7G9R9K7Y4r3J5kF8x9Qq1L5X0j7m2X3Y4Z5a6B7c8D9e0F1g2H3i4J5k6L7m8N9o0P1q2R3s4T5u6V7w8X9y0Z1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s0t1u2v3w4x5y6z7A8B9C0D1E2F3G4H5I6J7K8L9M0N1O2P3Q4R5S6T7U8V9W0X1Y2Z3a4b5c6d7e8f9g0h1i2j3k4l5m6n7o8p9q0r1s2t3u4v5w6x7y8z9A0B1C2D3E4F5G6H7I8J9K0L1M2N3O4P5Q6R7S8T9U0V1W2X3Y4Z5a6b7c8d9e0f1g2h3i4j5k6l7m8n9o0p1q2r3s4t5u6v7w8x9y0z1A2B3C4D5E6F7G8H9I0J1K2L3M4N5O6P7Q8R9S0T1U2V3W4X5Y6Z7a8b9c0d1e2f3g4h5i6j7k8l9m0n1o2p3q4r5s6t7u8v9w0x1y2z3A4B5C6D7E8F9G0H1I2J3K4L5M6N7O8P9Q0R1S2T3U4V5W6X7Y8Z9 terratest@example",
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
