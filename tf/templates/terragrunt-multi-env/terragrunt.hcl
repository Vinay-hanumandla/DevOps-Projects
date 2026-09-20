# last_verified: 2026-09-20 · terragrunt n/a
#
# Root Terragrunt configuration, included by every environment under envs/.
# It owns the remote-state backend so environment files only carry inputs.
# Each environment gets its own state key derived from its relative path,
# e.g. dev/terraform.tfstate, staging/terraform.tfstate, prod/terraform.tfstate.

remote_state {
  backend = "s3"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    # Placeholder — replace with the team's real state bucket and region.
    bucket  = "example-terraform-state"
    key     = "${path_relative_to_include()}/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
