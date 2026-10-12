# last_verified: 2026-10-12 · terraform n/a
#
# Dev root module variables. Defaults are dev-safe; override per environment
# in terraform.tfvars.

variable "project" {
  type    = string
  default = "example"
}

variable "environment" {
  type    = string
  default = "dev"
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