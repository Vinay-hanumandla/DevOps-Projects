# last_verified: 2026-10-12 · terraform n/a
#
# Prod environment: same module, same shape — only the inputs differ.
# Cost-centre and ownership tags are required here, not optional.

terraform {
  backend "s3" {
    bucket         = "example-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}