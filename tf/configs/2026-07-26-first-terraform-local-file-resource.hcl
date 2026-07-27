# last_verified: 2026-07-26 · terraform n/a

resource "local_file" "hello" {
  filename = "${path.module}/hello.txt"
  content  = "Hello, Terraform!"
}