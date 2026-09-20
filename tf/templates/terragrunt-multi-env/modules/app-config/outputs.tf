# last_verified: 2026-09-20 · terraform n/a

output "name_prefix" {
  description = "Prefix (<project>-<environment>) sibling modules prepend to resource names"
  value       = local.name_prefix
}

output "common_tags" {
  description = "Tag map sibling modules merge into every resource they create"
  value       = local.common_tags
}

output "environment" {
  description = "Echo of the environment input, for wiring into sibling module inputs"
  value       = var.environment
}
