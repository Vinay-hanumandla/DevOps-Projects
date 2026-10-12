# last_verified: 2026-10-12 · terraform n/a
#
# Provider/version constraints for the shared module. The null provider is
# used so the scaffold runs without cloud credentials; swap in real providers
# (AWS, Azure, GCP, Kubernetes, etc.) when the module creates real resources.

terraform {
  required_version = ">= 1.5"
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }
}