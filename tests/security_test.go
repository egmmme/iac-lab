package tests

import (
	"testing"

	terratest_terraform "github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestSecurityModulePlan(t *testing.T) {
	t.Parallel()

	rules := []map[string]interface{}{
		{
			"name":                       "AllowSSH",
			"priority":                   1001,
			"direction":                  "Inbound",
			"access":                     "Allow",
			"protocol":                   "Tcp",
			"source_port_range":          "*",
			"destination_port_range":     "22",
			"source_address_prefix":      "*",
			"destination_address_prefix": "*",
		},
	}

	terraformOptions := &terratest_terraform.Options{
		TerraformDir: "../modules/security",
		PlanFilePath: "security.tfplan",
		Vars: map[string]interface{}{
			"resource_group_name": "rg-terratest-security",
			"location":            "westeurope",
			"nsg_name":            "tt-nsg",
			"security_rules":      rules,
		},
	}

	plan := terratest_terraform.InitAndPlanAndShowWithStruct(t, terraformOptions)
	var hasNSG, hasRule bool
	for _, rc := range plan.ResourceChangesMap {
		if rc.Type == "azurerm_network_security_group" {
			hasNSG = true
		}
		if rc.Type == "azurerm_network_security_rule" {
			hasRule = true
		}
	}
	assert.True(t, hasNSG, "plan should include azurerm_network_security_group")
	assert.True(t, hasRule, "plan should include at least one azurerm_network_security_rule")
}
