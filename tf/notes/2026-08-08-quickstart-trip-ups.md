---
last_verified: 2026-08-08
tool_version: n/a
sources:
---

# Following the Terraform quickstart — what tripped me up

## What I did

I started with the official Terraform getting started guide. I created a single `main.tf` file with a provider block (local, since I don't have cloud credentials handy for a first run) and a simple resource to write a greeting file. Then I ran the classic sequence:

1. `terraform init` — downloaded the local provider plugin and set up the working directory
2. `terraform plan` — showed a preview of what would happen: create one file
3. `terraform apply` — had to type `yes` to confirm

After applying, I checked the working directory and saw a new `terraform.tfstate` file alongside `greeting.txt`. That's when things started making more sense.

## Got stuck on

- **The `yes` prompt on apply.** I kept forgetting to type `yes` and the command would just hang there. For automation this is annoying — I'll need `-auto-approve` later, but for learning I was glad it forces me to review the plan first.

- **State file dropped in the working directory.** I didn't realize Terraform would write `terraform.tfstate` right next to my config. It's fine for a single file, but I can already see how this becomes a mess with multiple files and team workflows. Remote state (S3, Terraform Cloud) is clearly the next thing to learn.

- **`terraform init` needs network access.** My first `init` failed because the corporate proxy was blocking the download of the local provider plugin. Took me a while to figure out that `init` isn't just a local operation — it fetches providers from the registry.

- **Variables prompt interactively.** When I added a `variable` block without a default, `terraform plan` stopped and asked me to enter a value. I thought my config was broken. Turns out you can pass `-var` on the command line or put values in a `terraform.tfvars` file.

- **"No changes" on second plan.** I ran plan again after apply and got "No changes. Your infrastructure matches the configuration." That was a relief — I was worried it would try to recreate things — but it took me a moment to understand that Terraform is idempotent: it compares desired state (config) against actual state (state file) and only acts on differences.

## What I'd try next

I want to experiment with variables and `terraform.tfvars` to avoid interactive prompts. Then I'll try splitting config into multiple files (`variables.tf`, `outputs.tf`) and see how `terraform fmt` cleans up formatting. After that, remote state backends and `terraform destroy` for cleanup are on my list.
