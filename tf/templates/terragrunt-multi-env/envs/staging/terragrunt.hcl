# last_verified: 2026-09-20 · terragrunt n/a
#
# Staging environment: mirrors prod inputs as closely as possible so release
# candidates are exercised under realistic names and tags.

include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules//app-config"
}

locals {
  environment = "staging"
}

inputs = {
  project      = "example"
  environment  = local.environment
  cost_center  = "staging-validation"

  extra_tags = {
    Owner = "platform-team"
  }
}
