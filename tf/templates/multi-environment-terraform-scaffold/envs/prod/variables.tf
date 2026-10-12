# last_verified: 2026-10-12 · terraform n/a
#
# Prod root module variables. Defaults are prod-safe; override per
# environment in terraform.tfvars.

variable "project" {
  type    = string
  default = "example"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "cost_center" {
  type    = string
  default = ""
}

variable "extra_tags" {
  type    = map(string)
  default = {}
}

variable "enabled" {
  type    = bool
  default = true
}