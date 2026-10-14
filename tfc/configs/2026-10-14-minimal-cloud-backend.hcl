# last_verified: 2026-10-14 · tfc n/a
terraform {
  cloud {
    organization = "example-org"
    workspaces {
      name = "example-workspace"
    }
  }
}
