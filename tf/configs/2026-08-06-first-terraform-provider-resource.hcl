# last_verified: 2026-08-06 · terraform n/a

terraform {
  required_providers {
    mycloud = {
      source  = "mycorp/mycloud"
      version = "1.0.0"
    }
  }
}

provider "mycloud" {}

resource "mycloud_instance" "web" {
  name          = "web-server"
  instance_type = "t2.micro"
}
