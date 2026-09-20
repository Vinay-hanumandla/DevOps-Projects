---
last_verified: 2026-09-20
tool_version: n/a
---

# Terragrunt multi-environment layout (dev / staging / prod)

## Purpose

This template shows one way to share a single reusable Terraform module across
three environments while keeping every per-environment difference in a small
Terragrunt inputs file. The module (`modules/app-config`) owns the naming and
tagging convention; each folder under `envs/` supplies only the values that
change between dev, staging, and prod. The root `terragrunt.hcl` owns the
remote-state backend so no environment file repeats it. This is the layout to
reach for when two or more environments deploy the same logical stack and
copy-pasted root modules have started drifting apart — one way to solve it,
not the only one; a dedicated composition module or a stack-style runner
would be the heavier-weight alternatives.

## Prerequisites

- A Terraform CLI and a Terragrunt CLI installed and on `PATH`.
- A state-bucket (or equivalent backend) the machine running Terragrunt can
  write to; the bucket name in the root config is a placeholder.
- An empty directory to copy this template into.

## Steps

1. Copy the whole `terragrunt-multi-env` directory into the new repo.
2. Open the root `terragrunt.hcl` and replace the placeholder backend settings
   (bucket name, region) with the team's own values.
3. Open each file under `envs/` (`dev`, `staging`, `prod`) and set `inputs`
   for that environment: at minimum `project` and `environment`, plus any
   extra tags or cost-centre labels the team tracks.
4. Point the `terraform.source` line in an environment file at the module the
   environment should deploy. The default points at the bundled
   `modules/app-config`; a real stack would add sibling modules (network,
   data store) the same way.
5. From the `envs/dev` folder, run a plan first and read it before touching
   the shared-cost environments:

   ```sh
   cd envs/dev
   terragrunt plan
   ```

6. When the dev plan looks right, roll the same command through the remaining
   environments, or run all three at once from the `envs` folder:

   ```sh
   cd ..
   terragrunt run-all plan
   ```

## Verify

- `terraform init -backend=false` followed by `terraform validate`, run inside
  `modules/app-config`, exits cleanly — this checks the shared module without
  needing backend credentials.
- `terragrunt run-all plan` from `envs/` produces three plans whose only
  differences are the per-environment inputs (name prefix, tags); nothing in
  the module source differs between environments.
- The state files land under one key prefix per environment
  (`dev/…`, `staging/…`, `prod/…`), so applying in one environment never
  rewrites another environment's state.

## Layout

```text
terragrunt-multi-env/
├── terragrunt.hcl              # shared backend, included by every env
├── envs/
│   ├── dev/terragrunt.hcl      # dev inputs only
│   ├── staging/terragrunt.hcl  # staging inputs only
│   └── prod/terragrunt.hcl     # prod inputs only
└── modules/
    └── app-config/
        ├── main.tf             # naming/tagging locals
        ├── variables.tf        # validated module inputs
        └── outputs.tf          # prefix, tags, environment
```
