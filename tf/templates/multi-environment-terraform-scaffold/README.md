---
last_verified: 2026-10-12
tool_version: n/a
---

# Multi-environment Terraform scaffold

## Purpose

This template shows one way to deploy the same logical stack into dev, staging,
and prod without copy-pasting root modules. The layout has two layers:

- `modules/example-module/` — a reusable module that owns resource creation.
- `envs/<env>/` — one folder per environment. Each folder has a tiny root module
  that calls the shared module, a `backend.tf` carrying the S3 state location
  for that environment, and a `terraform.tfvars` file with only the values that
  change between environments.

This is the layout to reach for when a single team deploys the same stack into
multiple environments and copy-pasted root modules have started drifting apart —
one way to solve it, not the only one; a Terragrunt-style `include`/`find_in_parent_folders`
layout or a dedicated composition module would be the heavier-weight alternatives.

## Prerequisites

- Terraform CLI installed and on `PATH`.
- An S3 bucket the machine running Terraform can write to; the bucket name in
  each `envs/<env>/backend.tf` is a placeholder.
- An empty directory to copy this template into.

## Steps

1. Copy the whole `multi-environment-terraform-scaffold` directory into the new
   repo.
2. Open each `envs/<env>/backend.tf` and replace the placeholder backend
   settings (bucket name, region, dynamodb table for locking) with the team's
   own values. Each environment keeps its own state key
   (`<env>/terraform.tfstate`) so applying in one environment never rewrites
   another environment's state.
3. Open each `envs/<env>/terraform.tfvars` file and set the inputs for that
   environment: at minimum `project` and `environment`, plus any extra tags or
   cost-centre labels the team tracks. The `main.tf` and `variables.tf` in
   each environment folder stay as they are — they are identical across
   environments by design.
4. From an environment folder, initialize and plan first against the
   lowest-cost environment:

   ```sh
   cd envs/dev
   terraform init
   terraform plan
   ```

5. When the dev plan looks right, repeat `terraform init` and `terraform plan`
   through the remaining environments, or script the loop:

   ```sh
   for env in dev staging prod; do
     (cd envs/$env && terraform init && terraform plan -out=$env.plan)
   done
   ```

## Verify

- `terraform init -backend=false` followed by `terraform validate`, run inside
  `modules/example-module`, exits cleanly — this checks the shared module
  without needing backend credentials.
- `terraform plan` in each `envs/<env>/` folder produces a plan whose only
  differences are the per-environment inputs (name prefix, tags); nothing in
  the module source differs between environments.
- The state files land under one key prefix per environment
  (`<env>/terraform.tfstate`), so applying in one environment never rewrites
  another environment's state.

## Layout

```text
multi-environment-terraform-scaffold/
├── README.md
├── modules/
│   └── example-module/
│       ├── main.tf              # example resource using validated inputs
│       ├── variables.tf         # validated inputs with regex/enum checks
│       ├── outputs.tf           # contract outputs for downstream consumers
│       └── versions.tf          # provider/version constraints
└── envs/
    ├── dev/
    │   ├── main.tf              # dev root: calls the shared module
    │   ├── variables.tf         # dev root inputs (defaults only)
    │   ├── backend.tf           # dev S3 state location
    │   └── terraform.tfvars     # dev inputs only
    ├── staging/
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── backend.tf
    │   └── terraform.tfvars
    └── prod/
        ├── main.tf
        ├── variables.tf
        ├── backend.tf
        └── terraform.tfvars
```