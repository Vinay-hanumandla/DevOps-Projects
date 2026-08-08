# last_verified: 2026-08-08 · terraform n/a

terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
    }
  }
}

provider "local" {}

resource "local_file" "greeting" {
  filename = "${path.module}/greeting.txt"
  content  = "Hello from Terraform!"
}
