---
last_verified: 2026-09-05
tool_version: n/a
sources: []
---

# Local vs remote Terraform state — a comparison

> Notes on choosing between local and remote state backends, and where the handoffs change when an individual workflow becomes a team workflow. This is one way to think about it; the Terraform documentation also covers backend configuration in more depth.

## Purpose

Terraform records the real-world resources it manages in a state file (`terraform.tfstate`). By default that file lives on disk in the working directory — the "local" backend. That is the right starting point for one person experimenting, but it does not scale to a team: the state sits on one laptop, there is no lock to keep two applies from racing, and if the file is lost or corrupted the mapping to real infrastructure is gone. A remote backend (S3, Terraform Cloud, the HTTP backend, etc.) moves that file into shared, durable, lockable storage. These notes compare the two and point out where the workflow shifts.

## When to use local state

Local state is the zero-config default. Reach for it when:

- One person is the only one making changes and the infrastructure is learning-only or throwaway.
- The project is small enough that "one laptop has the truth" is genuinely fine.
- You are following along with [the Terraform primer](../notes/0000-primer-terraform.md) or the [first-version-command install note](../notes/2026-07-26-install-terraform-and-run-first-version-command.md).

The local backend writes `terraform.tfstate` and a `terraform.tfstate.backup` copy alongside the config. That local backup is the only recovery path, so corruption or an accidental delete is the real risk.

## When to use remote state

A remote backend adds three things a team needs:

- **Shared access** — every developer and CI runner reads the same state file instead of one person's local copy.
- **Locking** — the backend blocks a second apply while one is in progress. The S3 backend pairs a state bucket with a DynamoDB lock table; Terraform Cloud handles locking through its own API.
- **Durability** — state lives in remote object storage, not on a single disk.

## A minimal comparison

| Aspect | Local backend | Remote backend (S3) |
|---|---|---|
| Where state lives | `terraform.tfstate` on disk | S3 bucket (one key per workspace) |
| Concurrent access | None — coordinate by hand | Automatic locking via DynamoDB |
| Recovery | Only the local `.backup` copy | Versioned in S3; lock table separate |
| Setup cost | None — works out of the box | Bucket + lock table + IAM policy |
| Best for | Solo, throwaway, learning | Teams, CI/CD, real infrastructure |

## How I'd migrate a solo project to remote state

I have not run this end-to-end against a live project, so treat the steps as a checklist rather than a guarantee. The S3 backend paired with a DynamoDB lock table is the standard team pattern in the Terraform documentation.

1. Add the backend block in the same directory as the config:

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "my-terraform-locks"
    encrypt        = true
  }
}
```

2. Run `terraform init` and confirm the state-migration prompt so the existing local state copies into S3.
3. Confirm the move with `terraform state list` — if it returns the expected resources, the remote backend is live.

## What tripped me up — things to confirm

- The migration prompt only appears on the first `terraform init` after adding the backend block. I have not confirmed whether re-running `init` on a machine with stale local state re-triggers the copy prompt, or silently adopts the remote copy.
- The IAM policy for the lock table needs to let CI acquire and release locks without granting delete-table rights. I have not tested the minimal policy yet.

## Verify

After migration, a second `terraform plan` should report no diff if nothing changed on the remote side. If it reports drift, the state copy in S3 does not match the last applied config — investigate before applying. I would also run `terraform state list` from a second machine to confirm the state is genuinely shared and not still local.

## What I'd try next

Compare the S3 backend against Terraform Cloud's native state storage. Cloud handles locking and versioning out of the box, removing the DynamoDB dependency — worth weighing that against the added cost of the Cloud tier. I also want to test the migration on a throwaway stack backed by a `null_resource` so I can confirm the lock-table permissions without touching real infrastructure.
