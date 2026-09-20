# last_verified: 2026-09-20 · terragrunt n/a
#
# Development environment: cheapest settings, verbose tagging so sandbox
# resources are easy to spot and clean up.

include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules//app-config"
}

locals {
  environment = "dev"
}

inputs = {
  project     = "example"
  environment = local.environment

  extra_tags = {
    Owner    = "platform-team"
    Lifespan = "short-lived"
  }
}
