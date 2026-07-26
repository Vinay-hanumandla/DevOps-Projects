---
last_verified: 2026-07-26
tool_version: n/a
sources:
---

I installed Terraform on my machine and ran `terraform version` to confirm it works.

I started by downloading the Terraform binary from the official releases page, then extracted it and moved the binary to a directory in my PATH. That way I can just type `terraform` from any terminal session.

Running `terraform version` confirmed the install — it printed the Terraform version and the Go runtime it was built with. That was the moment it clicked; I now have the tool on my machine and can start writing configuration.

Next I'll write my first Terraform file resource to see how the config loop works.