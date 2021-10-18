package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

// An example of how to test the Terraform module to create satellite IBM instance in examples/instance using Terratest.
func TestAccIBMSatelliteIBM(t *testing.T) {
	t.Parallel()

	// Unique name for an instance so we can distinguish it from any other cos instances provisioned in your IBM account
	expectedLocationName := fmt.Sprintf("terratest-%s", strings.ToLower(random.UniqueId()))

	// resource group
	expectedResourceGroup := "default"

	// region
	expectedRegion := "us-east"

	// is_prefix for resource name
	expectedPrefix := fmt.Sprintf("terratest-ibm-%s", strings.ToLower(random.UniqueId()))

	// Unique name for an instance so we can distinguish it from any other cos instances provisioned in your IBM account
	expectedClusterName := fmt.Sprintf("terratest-cluster-%s", strings.ToLower(random.UniqueId()))

	// Construct the terraform options with default retryable errors to handle the most common retryable errors in
	// terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../examples/satellite-ibm",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"ibm_region":                 expectedRegion,
			"location":                   expectedLocationName,
			"resource_group":             expectedResourceGroup,
			"is_prefix":                  expectedPrefix,
			"cluster":                    expectedClusterName,
			"create_cluster_worker_pool": true,
		},
	})

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)
}
