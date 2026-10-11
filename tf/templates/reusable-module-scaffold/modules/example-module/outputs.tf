# last_verified: 2026-10-11 · terraform n/a

output "resource_name" {
  description = "Computed base name for resources (name-environment)"
  value       = var.enabled ? "${var.name}-${var.environment}" : null
}

output "common_tags" {
  description = "Merged tag map for consistent labeling across resources"
  value       = merge(
    {
      Name        = var.enabled ? "${var.name}-${var.environment}" : null
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags,
  )
}

output "is_enabled" {
  description = "Echo of the enabled input for conditional logic in callers"
  value       = var.enabled
}