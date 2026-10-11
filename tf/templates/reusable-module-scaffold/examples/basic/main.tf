# last_verified: 2026-10-11 · terraform n/a

terraform {
  required_version = ">= 1.5"

  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

module "example" {
  source = "../../modules/example-module"

  name        = "myapp"
  environment = "dev"

  tags = {
    Owner       = "platform-team"
    CostCenter  = "engineering"
    Repository  = "github.com/org/repo"
  }
}

output "resource_name" {
  value = module.example.resource_name
}

output "common_tags" {
  value = module.example.common_tags
}