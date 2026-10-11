// last_verified: 2026-10-11 · terratest v0.45.0

package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestModuleVariablesValidation(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../",
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	name := terraform.Output(t, terraformOptions, "resource_name")
	assert.Equal(t, "example-dev", name)

	tags := terraform.OutputMap(t, terraformOptions, "common_tags")
	assert.Equal(t, "example-dev", tags["Name"])
	assert.Equal(t, "dev", tags["Environment"])
	assert.Equal(t, "terraform", tags["ManagedBy"])
}

func TestModuleDisabled(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"enabled": false,
		},
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	name := terraform.Output(t, terraformOptions, "resource_name")
	assert.Nil(t, name)

	enabled := terraform.Output(t, terraformOptions, "is_enabled")
	assert.Equal(t, "false", enabled)
}

func TestModuleValidationRejectsInvalidName(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"name":        "Invalid_Name",
			"environment": "dev",
		},
	}

	_, err := terraform.InitE(t, terraformOptions)
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "name must be lowercase")
}

func TestModuleValidationRejectsInvalidEnvironment(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"name":        "example",
			"environment": "production",
		},
	}

	_, err := terraform.InitE(t, terraformOptions)
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "environment must be one of")
}