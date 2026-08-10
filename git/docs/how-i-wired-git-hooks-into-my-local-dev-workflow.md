---
last_verified: 2026-07-30
tool_version: n/a
sources: []
---

# How I wired Git hooks into my local dev workflow

> A walkthrough of setting up Git hooks to catch issues before they reach the remote. Written as notes for someone doing the same.

## Purpose

Git hooks run client-side automation at points in the Git lifecycle — pre-commit, commit-msg, post-commit — and let developers enforce standards without touching the remote. The goal was to wire reusable hooks into a local dev setup so that linting, formatting, and commit-message checks run automatically.

## Steps

1. **Create the hooks directory.** Git looks for hooks in `.git/hooks/`. A `hooks/` directory at the repo root with a `.gitkeep` file allows the hook scripts to be tracked in version control, and a one-time install step symlinks each hook file into `.git/hooks/`.
2. **Write a pre-commit hook.** The hook runs `shellcheck` on changed shell scripts and `grep` for TODO markers that lack an owner. It exits non-zero to block the commit when a check fails.
3. **Write a commit-msg hook.** The hook validates that the commit message matches a conventional-commits pattern (`feat:`, `fix:`, `docs:`, etc.) and rejects messages that are too short.
4. **Write a post-commit hook.** The hook appends the commit hash and message to a local `CHANGELOG.log` file so there is a lightweight local trail.
5. **Install the symlinks.** A one-time `../hooks/install.sh` script creates symlinks from `.git/hooks/` to each hook in the repo's `hooks/` directory.

## Verify

To confirm the hooks are wired correctly, an intentional bad commit (`git commit -m "wip"`) was submitted and the commit-msg hook rejected it. A valid commit (`git commit -m "docs: update local workflow notes"`) then passed all hooks and appeared in `CHANGELOG.log`.

## Common errors

- **Hook not firing:** The symlink in `.git/hooks/` may be broken or missing execute permission. Run `ls -l .git/hooks/` and `file .git/hooks/<hook-name>` to confirm the symlink resolves and is executable.
- **Commit message rejected by commit-msg hook:** The hook expects a conventional-commits prefix. A message like `wip` or `fix bug` will be blocked; use `fix: resolve bug` instead.

## References

No external sources were used for this walkthrough.