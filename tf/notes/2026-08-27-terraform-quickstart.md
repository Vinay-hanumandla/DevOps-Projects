---
last_verified: 2026-08-27
tool_version: n/a
---

# Terraform quickstart trip-ups

> Following the official Terraform quickstart and writing down where I got stuck.

## What I did

I walked through the official Terraform quickstart today. The setup itself was straightforward: installed the CLI, initialized a new directory with `terraform init`, wrote a minimal provider and resource block, and ran `plan` and `apply`. The concepts clicked pretty fast — declare what you want, Terraform figures out how to get there.

## Where I tripped up

The first thing that confused me was provider block placement. I originally put the provider configuration inside the resource block instead of at the top level. Terraform didn't error immediately on `init`, but `plan` returned a vague message about missing provider configuration. I had to move the `required_providers` block and the `provider` block outside the resource to make it work. The docs show this clearly, but I skipped straight to the resource example and missed the setup context.

The second hiccup was state awareness. After `apply` succeeded, I kept wondering where the record of what was created lived. I found the `terraform.tfstate` file in the working directory, but I didn't realize at first that this single file is Terraform's entire source of truth for that workspace. Deleting it doesn't delete the real infrastructure — it just blinds Terraform. I ran `terraform destroy` to clean up once I understood that, but the gap between "config says what I want" and "state says what exists" is something I need to internalize before using this on anything real.

## What I'd do differently next time

Start with `terraform init` in an empty directory, add the provider block first, then the resource, and run `terraform plan` after each change. Also set `TF_VAR_*` environment variables early so I don't hardcode region or project values in the config while I'm experimenting.

## What I'll cover next

I want to try variables and outputs next, then move into multi-resource configs and remote state. The quickstart gave me enough context to start experimenting without hand-holding.
