# last_verified: 2026-10-12 · terraform n/a
#
# Shared naming and tagging module, included by every environment under
# envs/. It computes the name prefix and tag map every sibling module and
# every environment reuses, so renaming happens in exactly one place.
# Environment folders call this module with only their own variables;
# nothing about the stack is repeated.

locals {
  name_prefix = "${var.project}-${var.environment}"

  common_tags = merge(
    {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.cost_center != "" ? { CostCenter = var.cost_center } : {},
    var.extra_tags,
  )
}

resource "null_resource" "app" {
  triggers = {
    name_prefix = local.name_prefix
    cost_center = var.cost_center
    tags        = jsonencode(local.common_tags)
  }
}