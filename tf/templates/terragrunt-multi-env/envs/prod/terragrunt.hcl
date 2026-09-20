# last_verified: 2026-09-20 · terragrunt n/a
#
# Prod environment: same module, same shape — only the inputs differ.
# Cost-centre and ownership tags are required here, not optional.

include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules//app-config"
}

locals {
  environment = "prod"
}

inputs = {
  project      = "example"
  environment  = local.environment
  cost_center  = "production-workloads"

  extra_tags = {
    Owner       = "platform-team"
    Criticality = "high"
  }
}
