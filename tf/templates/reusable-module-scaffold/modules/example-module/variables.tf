# last_verified: 2026-10-11 · terraform n/a

variable "name" {
  description = "Base name for all resources created by this module"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,61}$", var.name))
    error_message = "name must be lowercase alphanumeric with dashes, start with a letter, and be at most 63 characters."
  }
}

variable "environment" {
  description = "Deployment environment; controls naming conventions and defaults"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod", "test"], var.environment)
    error_message = "environment must be one of: dev, staging, prod, test."
  }
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "enabled" {
  description = "Whether to create resources; allows toggling the entire module"
  type        = bool
  default     = true
}