# last_verified: 2026-09-20 · terraform n/a
#
# Shared naming and tagging convention. This module creates no resources
# itself; it computes the name prefix and tag map every sibling module and
# every environment reuses, so renaming happens in exactly one place.

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
