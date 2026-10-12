# last_verified: 2026-10-12 · terraform n/a
#
# Dev environment: cheapest settings, verbose tagging so sandbox resources
# are easy to spot and clean up.

terraform {
  backend "s3" {
    bucket         = "example-terraform-state"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}