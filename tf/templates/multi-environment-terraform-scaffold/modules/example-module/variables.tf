# last_verified: 2026-10-12 · terraform n/a

variable "project" {
  description = "Short project slug used as the first half of every resource name"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.project))
    error_message = "project must be lowercase alphanumeric with dashes, starting with a letter."
  }
}

variable "environment" {
  description = "Deployment environment; controls naming conventions and defaults"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "cost_center" {
  description = "Cost-centre label; empty means no CostCenter tag is emitted"
  type        = string
  default     = ""
}

variable "extra_tags" {
  description = "Additional tags merged over the convention defaults"
  type        = map(string)
  default     = {}
}

variable "enabled" {
  description = "Whether to create resources; allows toggling the entire module"
  type        = bool
  default     = true
}