---
last_verified: 2026-08-12
tool_version: n/a
sources: []
---

# Debugging and Profiling a Bash Script with set -x and Trace Traps

> How to trace where a bash script fails and profile where the time goes, using only `set -x` and the built-in trace traps.

## Purpose

Bash provides built-in tracing and trap mechanisms that reveal what a script is doing at runtime without requiring an external debugger. `set -x` prints each command before it executes, while the `DEBUG` and `RETURN` traps hook into the shell's execution lifecycle to log command flow and function timing. Together they address two common debugging needs: pinpointing the exact command that fails, and identifying which functions consume the most runtime.

## When to use

Use `set -x` when a script exits silently or produces an unexpected result and the traceback does not indicate the failing line. Use a `DEBUG` trap when you need conditional or structured logging around command execution rather than raw trace output. Use a `RETURN` trap with timestamps when profiling function-level timing — for example, finding which of several data-processing functions dominates a deployment script's runtime.

These tools are complementary to `set -euo pipefail` (covered in `strict-mode-trap-patterns.md`). `set -x` and the trace traps do not change error behavior; they only add observability. That separation makes them safe to add to a script that already uses strict mode.

## Prerequisites

- A Bash 4.0+ shell (all systems targeted by modern DevOps tooling meet this).
- Familiarity with file descriptor manipulation (`exec 2>file`) if redirecting trace output.
- No external dependencies; all features are shell built-ins.

## Steps

### 1. Turn on xtrace with a readable PS4

`set -x` prints each command to stderr before it runs. The default trace line is just the command, which becomes difficult to map back to source locations in longer scripts. Setting `PS4` prefixes each traced command with the source file and line number:

```bash
set -x
PS4='+ ${BASH_SOURCE}:${LINENO}: '
```

With this `PS4`, a trace line reads `+ script.sh:42: deploy() {`, so the last few trace lines before a failure point directly at the problematic line.

### 2. Use a DEBUG trap for a running commentary

A `trap ... DEBUG` fires before every simple command. Logging `BASH_COMMAND` and its exit code produces a command-by-command timeline:

```bash
trap 'printf "cmd: %s -> %s\n" "${BASH_COMMAND}" "$?"' DEBUG
```

`BASH_COMMAND` holds the command about to execute, and `$?` holds the exit code of the previous command. Combined with `set -x`, the output can become noisy; enabling both only during targeted debugging sections keeps logs readable.

### 3. Profile with RETURN traps and timestamps

`trap ... RETURN` fires whenever a function returns. Wrapping a script's functions so each one records its elapsed time on exit produces a per-function profile:

```bash
profile() { printf "%-20s %s\n" "$(caller)" "$(date +%s.%N)"; }
trap profile RETURN
```

`date +%s.%N` provides sub-second resolution, and `caller` names the function that just returned. After the script completes, the timestamp deltas show which functions account for most of the runtime.

## Verify

Run the script with the traps active and examine the trace output. With `PS4` set, the last trace lines before a failure should point to the exact unquoted variable or missing file that caused the exit. With the `RETURN` trap active, sorting the output by elapsed time highlights the functions that consumed the most runtime. Redirect trace output to a file with `exec 2>trace.log` when the volume of stderr makes terminal output hard to follow.

## Common errors

- `set -x` output and `DEBUG` trap output interleave on stderr, which can make logs hard to read. Redirect the trace to a file with `exec 2>trace.log` and review it after the run rather than reading live terminal output.
- The `DEBUG` trap fires inside every subshell and loop body, so enabling it globally produces a flood of entries. Scope it to the section under investigation by setting and clearing the trap around the relevant code block.
- `trap` handlers inherit the `set -e` behavior when strict mode is active. A failing command inside a trap handler causes the script to abort. Use `set +e` locally inside the handler if cleanup commands are expected to fail.

## What I'd try next

Add a `trap ... ERR` that logs `"Script failed with exit code $? on line $LINENO"` so future failures surface their location without needing to re-enable xtrace. Run `shellcheck` as a static-analysis gate before debugging sessions so the trace tools are needed less often.
