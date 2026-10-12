# last_verified: 2026-10-12 · terraform n/a
#
# Staging root module: calls the shared example-module with staging inputs only.
# Nothing about the stack is repeated here beyond the module call.
# The values that differ between environments live in terraform.tfvars.

module "example_module" {
  source = "../../modules/example-module"

  project     = var.project
  environment = var.environment
  cost_center = var.cost_center
  extra_tags  = var.extra_tags
  enabled     = var.enabled
}