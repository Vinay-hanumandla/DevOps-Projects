# last_verified: 2026-09-02 · terraform n/a

terraform {
  required_providers {
    null = {
      source = "hashicorp/null"
    }
  }
}

provider "null" {}

# The null provider manages no real infrastructure — it just runs provisioners.
# I'm using it here to practice the provider + resource block shape before
# wiring up a real cloud provider (AWS, in my next step).
resource "null_resource" "web_setup" {
  # triggers lets me see what would change if any value is updated.
  # Without this, null_resource has no state to track and re-runs every plan.
  triggers = {
    version = "1"
  }

  provisioner "local-exec" {
    command = "echo 'hello from null_resource'"
  }
}
