---
last_verified: 2026-08-25
tool_version: "5.3.15"
sources:
  - https://lists.gnu.org/archive/html/bash-announce/2025-07/msg00000.html
  - https://mirrors.ibiblio.org/gnu/bash/bash-5.3-patches/
  - https://www.mechanicalrock.io/blog/modern-bash
  - https://www.youngju.dev/blog/culture/2026-05-16-modern-bash-shell-scripting-2026-bash-5-2-zsh-5-9-fish-4-nushell-shellcheck-bashly-justfile-deep-dive.en
  - https://github.com/koalaman/shellcheck/releases/tag/v0.11.0
---

# Bash 5.3 migration guide

## Purpose

Document the behavioral and syntactic changes introduced in Bash 5.3 so existing scripts can be audited, updated, and validated against the new runtime. Focus areas are the new command-substitution syntax, `GLOBSORT`, `shopt` additions, and incompatible changes to the `test` builtin and interactive job notification.

## When to use

Use this guide when upgrading a codebase to Bash 5.3 or when auditing scripts for compatibility with patchlevel 5.3.15+. It applies to scripts that rely on command substitution, pathname expansion ordering, strict-mode options, or sourcing behavior.

## Prerequisites

- Bash 5.3.15 or later installed (`bash --version`).
- ShellCheck 0.11.0 or later for static validation.
- A test harness (e.g., `bats-core`) to verify behavioral changes before deploying.

## Steps

### 1. Adopt the new command-substitution syntax

Bash 5.3 introduces `${ command; }` and `${|command;}`. Both execute in the current shell context instead of forking a subshell.

```bash
# Captures stdout; failures propagate the inner exit status.
result=${ grep -c "^error" app.log; }

# Leaves output in REPLY; useful for side-effect commands.
${ printf '%s\n' "$var" | sed 's/ /_/g'; }
echo "$REPLY"
```

`${ command; }` is a drop-in replacement for legacy `` `cmd` `` and `$(cmd)` when avoiding forks matters (e.g., inside loops that modify shell state). `${|command;}` is intended for commands whose return value is used indirectly.

### 2. Control pathname expansion ordering with `GLOBSORT`

`GLOBSORT` is a new `shopt` option that switches pathname expansion from byte-value (LC_COLLATE-dependent) to lexical dictionary order.

```bash
shopt -s globsort
for f in *.log; do echo "$f"; done
# 1-access.log 2-access.log 10-access.log   (dictionary order)
# vs. default: 1-access.log 10-access.log 2-access.log (byte order)
```

Enable it at the top of scripts that sort file lists for human-readable output or deterministic CI behavior.

### 3. Review `shopt` additions and defaults

Key `shopt` changes in 5.3:

| Option | Default | Effect |
|---|---|---|
| `bash_source_fullpath` | off | Populates `BASH_SOURCE` with absolute paths. |
| `inherit_errexit` | off in 4.x, on in 5.x | Propagates `set -e` into functions and command substitutions. |
| `MULTIPLE_COPROCS` | on | Allows multiple concurrent coprocesses. |
| `array_expand_once` | off | Replaces deprecated `assoc_expand_once`. |

Verify that scripts relying on `BASH_SOURCE` relative paths either set `bash_source_fullpath` or normalize paths themselves.

### 4. Audit `test` builtin usage

The `test` builtin now parses parenthesized subexpressions differently when invoked with more than four arguments. Scripts that use complex parenthesized expressions with `[` or `test` should be re-run under 5.3 to catch altered precedence.

```bash
# Risky pattern — validate under Bash 5.3
if [ \( "$a" -gt 0 \) -a \( "$b" -lt 10 \) ]; then
  echo "ok"
fi
```

Prefer `[[ ... ]]` for compound tests; it is unaffected by this change.

### 5. Re-test sourced scripts for job-notification changes

Interactive shells no longer notify about completed jobs while sourcing a script. If a sourced file relies on job-control messages (e.g., `wait` output triggering user prompts), behavior may differ.

## Verify

```bash
bash --version | head -1
# Expected: GNU bash, version 5.3.15(...)

shellcheck --version | head -1
# Expected: ShellCheck - shell script analysis tool

shellcheck -S error -s bash -x script.sh
# Zero warnings or errors.
```

Run the full test suite under Bash 5.3.15. Pay special attention to any `test` or `[` invocations with parentheses and any `source`d libraries that manipulate job state.

## Common errors

- **Silent precedence change in `[`**: Parenthesized `test` expressions with >4 arguments parse differently. Migrate to `[[ ... ]]` where possible.
- **`local var=$(cmd)` masks failures**: Under `set -e`, the assignment itself succeeds even if `cmd` fails, so the script continues. Assign on a separate line when the exit status matters.
- **`PIPESTATUS` overwritten immediately**: Read `${PIPESTATUS[0]}` right after a pipeline; the next command resets the array.
- **`(( i++ ))` exits under `set -e` when `i=0`**: The arithmetic command returns 1 because the expression evaluates to 0. Use `i=$((i + 1))` or `(( ++i ))` or guard with `|| true`.

## References

- Bash 5.3 announcement (release and patch details): https://lists.gnu.org/archive/html/bash-announce/2025-07/msg00000.html
- Bash 5.3 patch archive: https://mirrors.ibiblio.org/gnu/bash/bash-5.3-patches/
- Modern Bash patterns and strict-mode options: https://www.mechanicalrock.io/blog/modern-bash
- Strict-mode contention and `inherit_errexit`: https://mywiki.wooledge.org/BashFAQ/105
- ShellCheck 0.11.0 release (Bash 5.3 checks): https://github.com/koalaman/shellcheck/releases/tag/v0.11.0
