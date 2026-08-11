---
last_verified: 2026-08-11
tool_version: n/a
sources: []
---

# Terraform — coverage check

> How I compared the `tf/` folder against the coverage table and fixed the Terraform counts.

## What I did

I opened the `tf/` directory and counted files by category, then compared those numbers to the coverage table. The table was listing Terraform as 1 config, 1 note, and 1 script even though I had more on disk, and it was missing three files I added on 2026-08-08.

## Steps

1. **Listed the folder.** I ran `find tf -type f` from the repo root and grouped the output by category.
2. **Counted what was actually there.** `tf/configs/` had 3 files, `tf/notes/` had 3 (including the primer), `tf/docs/` had 1, and `tf/scripts/` had 1.
3. **Fixed the coverage table.** I set configs to 3, notes to 3, and scripts to 1 so the table matches the folder, and surfaced the files I'd missed.
4. **Verified links.** I confirmed each file exists on disk before referencing it.

## Terraform coverage table

| Category | Count | Files |
|----------|-------|-------|
| configs | 3 | `2026-07-26-first-terraform-local-file-resource.hcl`, `2026-08-06-first-terraform-provider-resource.hcl`, `2026-08-08-minimal-provider-resource.hcl` |
| notes | 3 | `0000-primer-terraform.md`, `2026-07-26-install-terraform-and-run-first-version-command.md`, `2026-08-08-quickstart-trip-ups.md` |
| docs | 1 | `2026-08-06-terraform-project-structure.md` |
| scripts | 1 | `2026-08-08-tf-init-plan-apply.sh` |

## Key links

- **`tf/configs/2026-08-08-minimal-provider-resource.hcl`** — the minimal provider and resource config that was missing from the previous coverage count.
- **`tf/notes/2026-08-08-quickstart-trip-ups.md`** — the quickstart trip-ups note that also needed surfacing.
- **`tf/scripts/2026-08-08-tf-init-plan-apply.sh`** — the init/plan/apply workflow script.

## Got stuck on

- The primer (`0000-primer-terraform.md`) lives in `notes/` alongside the dated entries. I decided to keep it in the notes total for Terraform, which matches how the README coverage table counts it.
- The task description said "script count is 1 (not 1)", which reads like a typo — there is exactly one script and the table already showed 1, so I left it alone.

## What I'd try next

I want to turn this into a small Bash script that regenerates the table straight from the filesystem, so I stop catching these mismatches by hand every time I drop a new file into a folder.