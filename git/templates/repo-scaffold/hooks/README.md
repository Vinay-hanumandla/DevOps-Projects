---
last_verified: 2026-09-07
tool_version: n/a
sources: []
---

# Hooks

This folder holds the repository's client-side Git hooks. They run locally
before a commit is created or a message is accepted, so they catch problems
early without needing a remote to enforce them.

## Files

- **`pre-commit`** — runs the checks that must pass before a commit is
  created: secret scanning, ShellCheck on staged shell scripts, and the
  project's own test suite if a `Makefile` with a `test` target exists.
- **`commit-msg`** — enforces the conventional-commit format on the message
  passed in as `$1`.

## Install

Point Git at this folder so the hooks are picked up automatically:

```bash
git config core.hooksPath hooks
```

Make sure the hooks are executable:

```bash
chmod +x hooks/pre-commit hooks/commit-msg
```

## How they work

Git calls a hook by name when the corresponding event happens. The hook
receives arguments on its command line — `commit-msg` receives the path to the
temporary message file as `$1`. If a hook exits non-zero, Git aborts the
operation.

These hooks are intentionally small. Each one does one job and reports a
single `PASS` or `FAIL` line, so the failure mode is obvious in the terminal.

## Disabling

To skip a hook for a single operation, use the `--no-verify` flag on the
relevant command (`git commit --no-verify`). To disable a hook entirely,
remove it from this folder or unset `core.hooksPath`. Do not leave a broken
hook in place — it will fail every commit and nobody will work around it by
skipping verification.