---
last_verified: 2026-08-25
tool_version: n/a
sources:
  - https://www.mechanicalrock.io/blog/modern-bash
  - https://blog.damonkohler.com/Garden/Production-Bash-Patterns
  - https://github.com/koalaman/shellcheck/releases/tag/v0.11.0
  - https://github.com/bats-core/bats-core/releases/tag/v1.14.0
---

# Production Bash scaffold

A reference layout for CI-safe Bash scripts with structured logging, retry semantics,
advisory file locking, and environment validation.

## Purpose

Centralize recurring production concerns—logging, retries, locking, and environment
checks—so individual scripts stay small and testable.

## When to use

Use this scaffold when a Bash script runs in CI or cron, touches shared resources,
or must survive transient failures without manual intervention.

## Prerequisites

- Bash 4.1+ (for `exec {fd}` file-descriptor syntax used by `with_flock`)
- bats-core 1.14.0+
- ShellCheck 0.11.0+ (lint gate)

## Structure

```
.
├── bin/
│   └── app            # executable entry point
├── lib/
│   ├── logging.sh     # log / warn / err / fail
│   ├── retry.sh       # with_retry
│   ├── flock.sh       # with_flock
│   └── env.sh         # require_cmd / env_assert
└── tests/
    └── app.bats       # bats-core test harness
```

## Steps

1. Copy the `bash-production-scaffold` directory.
2. Replace `bin/app` with the real entry point; keep `main()` as the orchestrator.
3. Add domain-specific helpers to `lib/`; source them in `bin/app`.
4. Write tests in `tests/*.bats`; run `bats tests/` locally and in CI.

## Verify

```sh
shellcheck -S error bin/**/*.sh lib/**/*.sh
bats tests/
```

## Common errors

- **`flock: No locks available`** — another instance holds the lock; check for stale
  PID files or long-running jobs.
- **`set -e` silently ignores failures** — failures inside `cmd | other`,
  `if cmd; then`, or `cmd || true` do not trigger errexit. Pair with `set -o pipefail`
  and `set -E` for ERR-trap inheritance.
- **Unquoted variable expansions** — ShellCheck flags SC2086; always quote `"$@"`
  and `"${var}"` unless intentional word splitting is required.

## References

- [Modern Bash Shell Scripting](https://www.mechanicalrock.io/blog/modern-bash)
- [Production Bash Patterns](https://blog.damonkohler.com/Garden/Production-Bash-Patterns)
- [ShellCheck v0.11.0 release notes](https://github.com/koalaman/shellcheck/releases/tag/v0.11.0)
- [bats-core v1.14.0 release notes](https://github.com/bats-core/bats-core/releases/tag/v1.14.0)
