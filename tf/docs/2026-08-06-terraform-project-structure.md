---
last_verified: 2026-08-06
tool_version: n/a
sources: []
---

# Terraform project structure

> First-day notes on how the tf/ folder fits into the project.

## What I set up

I created a `tf/` folder alongside the other tool folders (`bash/`, `docker/`, `git/`, etc.) so Terraform configs live in their own dedicated space. Inside, I split things into subfolders:

- `tf/configs/` — HCL files for providers, resources, and modules
- `tf/notes/` — learning notes and primer docs
- `tf/docs/` — project-level documentation about how Terraform fits in the repo

## Why this layout

Keeping Terraform in its own folder makes it easy to find. It follows the same pattern as the other tool folders — each tool gets its own top-level directory with `configs/`, `notes/`, `docs/`, and `scripts/` as needed. I can point CI or deployment scripts at `tf/configs/` without guessing.

## What I learned

I initially put Terraform files at the repo root, but that got messy fast. Once I moved them into `tf/`, it was much clearer. The `tf/docs/` folder is where I write notes about the project structure itself — like this file.
