---
last_verified: 2026-10-14
tool_version: "n/a"
---

# Terraform Cloud — quick primer

> First-day notes for someone who's never used Terraform Cloud. Personal voice, plain language.

## What is it?

I just learned Terraform Cloud is the hosted service around Terraform, the tool I already use to describe infrastructure in config files. If plain Terraform is like running builds on my own laptop, Terraform Cloud is like moving that to a shared team service — it stores my state files, runs my plans and applies in a consistent place, and gives the team one UI to look at.

I ran nothing yet, just read around. My mental model now: I still write the same blocks and resources locally, but instead of keeping the state file on disk or in a bucket I manage myself, I point a `cloud` block at an organization and workspace and let the service hold the state and run the workflow.

## What does it do?

It lets me keep remote state in one locked place so teammates stop overwriting each other, queue up runs (plan first, then apply) from pushes or from the UI, and share input values through workspace variables instead of passing files around. I can also gate who is allowed to approve an apply.

## Why does it exist?

Before this, my workflow would have been local state files or a backend I wire up and guard myself, plus a lot of chat messages like "are you running an apply right now?". That gets scary with two people touching the same environment. Teams that live in Terraform day-to-day — folks managing shared test or team environments — wanted locking, history of runs, and one place to see what changed. That is the gap this fills for me.

## Key terminology

- **Organization** — the top-level account my team shares. Example: I join `example-org` and see every workspace my team owns.
- **Workspace** — a named slot tying one config directory to one state file. Example: a workspace called `example-workspace` holds the state for my demo stack.
- **Run** — one plan or apply cycle inside a workspace. Example: I push a change and a run shows me the plan output before I confirm.
- **State** — the record of what Terraform last created. Example: after an apply, the workspace state lists each resource and its IDs.
- **Variables** — input values set on the workspace UI instead of my shell. Example: I set `region = "example-region"` as a workspace variable.
- **VCS connection** — linking a repo so pushes trigger runs. Example: connecting my demo repo so every merge queues a speculative plan.

## A tiny example

The smallest hello-world I found is pointing my config at a workspace:

```hcl
terraform {
  cloud {
    organization = "example-org"
    workspaces {
      name = "example-workspace"
    }
  }
}
```

This tells Terraform to store state and run operations inside that workspace instead of on my laptop.

## What I'll cover next

I want to click through workspaces next — what tabs and settings I actually see — and then try the minimal backend block above for real. After that I can look at how runs get triggered from a repo push.
