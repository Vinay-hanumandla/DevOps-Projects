---
last_verified: 2026-08-11
tool_version: n/a
sources:
  - https://khimananda.com/blog/bash-scripting-for-devops-patterns-and-pitfalls
---

# Debugging and Profiling a Bash Script with set -x and Trace Traps

> How to trace where a bash script fails and profile where the time goes, using only `set -x` and the built-in trace traps.

## Purpose

A deployment helper script kept failing on a line that gave no context, and the runtime was higher than expected. Two built-in bash facilities solved both problems without pulling in a debugger: `set -x` for tracing every command that runs, and the `DEBUG`/`RETURN` trace traps for timing function execution.

## Steps

### 1. Turn on xtrace with a readable PS4

`set -x` prints each command to stderr before it runs. The default trace line is just the command, which stops being useful once a script grows past a screenful. Setting `PS4` prefixes each traced command with the source file and line number:

```bash
set -x
PS4='+ ${BASH_SOURCE}:${LINENO}: '
```

A trace line then reads like `+ script.sh:42: deploy() {`, so the failing command maps straight back to a location in the file.

### 2. Use a DEBUG trap for a running commentary

A `trap ... DEBUG` fires before every command. Logging the command and its eventual exit code gives a command-by-command timeline:

```bash
trap 'printf "cmd: %s -> %s\n" "${BASH_COMMAND}" "$?"' DEBUG
```

This is one way to build a timeline; combined with `set -x` the output gets noisy, so it helps to only enable both while hunting a specific failure.

### 3. Profile with RETURN traps and timestamps

`trap ... RETURN` fires whenever a function returns. Wrapping the script's heavy functions so each one records its elapsed time on exit gives a per-function profile:

```bash
profile() { printf "%-20s %s\n" "$(caller)" "$(date +%s.%N)"; }
trap profile RETURN
```

`date +%s.%N` provides sub-second resolution, and `caller` names the function that just returned.

## Verify

With `PS4` set, the failing run's last trace lines pointed at the exact unquoted variable that was empty. With the `RETURN` trap active, the timestamp deltas showed the script spending most of its runtime in a `find` loop that should have been constrained — the profile confirmed the suspicion the first read-through raised.

## Got stuck on

- `set -x` output and the `DEBUG` trap output interleave on stderr, which made the log hard to read. Redirecting the trace to a file (`exec 2>trace.log`) and reading it after the run fixed that.
- The `DEBUG` trap also fires inside every subshell and loop body, so enabling it globally produced a flood. Scoping it to the section under debug kept the output usable.

## What I'd try next

Add a permanent `trap ... ERR` that logs `"Script failed with exit code $? on line $LINENO"` so future failures surface their location by default, and run `shellcheck` as a static gate so the trace tools are needed less often.

## References

- https://khimananda.com/blog/bash-scripting-for-devops-patterns-and-pitfalls
