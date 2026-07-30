---
last_verified: 2026-07-30
tool_version: n/a
sources:
  - https://dynamicbytes.blog/bash-scripting-for-beginners-in-2026-automate-your-linux-workflow
---

# Wiring Bash Strict Mode and Trap Patterns into a Script Workflow

> Notes on integrating `set -euo pipefail` and signal-handling traps into a Bash-based system report tool.

## Purpose

This doc describes the decisions and missteps involved when adding strict-mode guards and trap-based cleanup to a directory-based system report script (`bash/scripts/system-report-tool.sh`). The goal was to improve reliability without over-engineering the error handling.

## When to use strict mode

`set -euo pipefail` is the recommended starting point for any non-trivial Bash script. It catches three common failure modes:

- `-u` prevents use of unset variables, which is especially easy to overlook in parameter expansions like `${VAR:-default}`.
- `-e` causes the script to exit on any command that returns a non-zero exit code.
- `pipefail` ensures that a pipeline reports the exit code of the first failing command instead of silently succeeding if the last command in the chain succeeds.

One gotcha is that `(( 0 ))` returns exit code 1 under `-e`, which can kill a script unexpectedly. The `wc -l` approach used in the report tool avoids this. Another is that `set -e` is suspended inside `if`/`while`/`&&`/`||` contexts, so commands in those branches that are expected to fail must still be handled explicitly.

## Trap patterns

Using `trap` to clean up temporary files or restore state on exit is straightforward, but there are edge cases:

```bash
cleanup() {
    rm -f "${tmpfile:-}"
}
trap cleanup EXIT
```

The `EXIT` signal fires on normal completion and on error-triggered exits, which makes it the right choice for cleanup that should always run. However, `trap` handlers inherit the `set -e` behavior, so a failing command inside the handler will itself cause the script to abort unless `set +e` is used locally.

## What tripped me up

- Mixing `set -e` with `find ... | while read` — the `while` loop runs in a subshell, so failures inside it are hidden from `-e`. The report tool works around this by capturing `find` output into variables first.
- Quoting `"$@"` in the `usage()` function when printing error messages — an unquoted `$@` in a `printf` format string can behave unexpectedly if arguments contain format specifiers.

## Verification

Running the script against a test directory with a mix of file types produces the expected counts. The JSON output path correctly serializes fields, and the text output formats sizes and dates consistently.

## What I'd try next

Adding optional flags for filtering by file extension or date range. The `getopts` parser in the script only handles short flags long-style, which gets unwieldy — a dedicated parsing library would be cleaner for more than a handful of options.

## References

- https://dynamicbytes.blog/bash-scripting-for-beginners-in-2026-automate-your-linux-workflow