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

resource "null_resource" "example" {
  count = var.enabled ? 1 : 0

  triggers = {
    name           = var.name
    environment    = var.environment
    common_tags    = jsonencode(module.example.outputs.common_tags)
    resource_name  = module.example.outputs.resource_name
  }
}

output "example_id" {
  description = "ID of the example resource (null_resource always returns empty string when triggered)"
  value       = var.enabled ? null_resource.example[0].id : null
}