package tests

import (
	"testing"

	terratest_terraform "github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestNetworkModulePlan(t *testing.T) {
	t.Parallel()

	terraformOptions := &terratest_terraform.Options{
		TerraformDir: "../modules/network",
		PlanFilePath: "network.tfplan",
		Vars: map[string]interface{}{
			"resource_group_name": "rg-terratest-network",
			"location":            "westeurope",
			"vnet_name":           "tt-vnet",
			"subnet_name":         "tt-subnet",
			"public_ip_name":      "tt-pip",
			"address_space":       []string{"10.10.0.0/16"},
			"subnet_prefixes":     []string{"10.10.1.0/24"},
		},
	}

	plan := terratest_terraform.InitAndPlanAndShowWithStruct(t, terraformOptions)
	// Assert basic resources exist in plan
	var hasVnet, hasSubnet, hasPip bool
	for _, rc := range plan.ResourceChangesMap {
		if rc.Type == "azurerm_virtual_network" {
			hasVnet = true
		}
		if rc.Type == "azurerm_subnet" {
			hasSubnet = true
		}
		if rc.Type == "azurerm_public_ip" {
			hasPip = true
		}
	}
	assert.True(t, hasVnet, "plan should include azurerm_virtual_network")
	assert.True(t, hasSubnet, "plan should include azurerm_subnet")
	assert.True(t, hasPip, "plan should include azurerm_public_ip")
}
