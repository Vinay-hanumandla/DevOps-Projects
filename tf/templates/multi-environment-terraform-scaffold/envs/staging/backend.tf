# last_verified: 2026-10-12 · terraform n/a
#
# Staging environment: mirrors prod inputs as closely as possible so release
# candidates are exercised under realistic names and tags.

terraform {
  backend "s3" {
    bucket         = "example-terraform-state"
    key            = "staging/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}