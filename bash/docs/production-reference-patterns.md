---
last_verified: 2026-09-29
tool_version: "5.3"
sources:
  - https://khimananda.com/blog/bash-scripting-for-devops-patterns-and-pitfalls
  - https://cgit.git.savannah.gnu.org/cgit/bash.git/log
---

# Bash production reference: shell options, traps, process substitution, and coprocess patterns

## Purpose

A concise production reference for the four Bash mechanisms that reliably
hardened scripts depend on: shell option flags for fail-fast behavior, signal
traps for guaranteed cleanup, process substitution for piping into commands
that expect file arguments, and coprocesses for long-lived background workers
with bidirectional I/O. Each section includes a copyable pattern and the failure
mode it prevents.

## When to use

Apply these patterns when authoring or auditing any Bash script that runs in CI,
operates on infrastructure, or sits between a developer action and a system
change. Quick one-liners do not require the full header, but any script that
persists state, calls external commands, or runs unattended should combine at
least the shell options, a dependency guard, and a trap. Together these eliminate
the class of failures that degrade observability: silent variable expansion,
swallowed pipeline errors, leftover temp files blocking subsequent runs, and
fork/exec overhead from repeatedly spawning the same helper.

## Prerequisites

- Bash 5.3 installed (`bash --version`).
- ShellCheck available for static analysis.
- A test harness such as `bats-core` for runtime assertions.

## Steps

### 1. Shell options and header guard

Start every script with a consistent header that enforces strict behavior and
predictable field splitting:

```bash
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
shopt -s globstar nullglob
```

The flags and options serve distinct roles:

| Option | Purpose |
|---|---|
| `-e` | Exit immediately when a command returns non-zero. |
| `-u` | Treat expansion of unset variables as an error. |
| `-o pipefail` | A pipeline fails if any command in the chain fails. |
| `IFS=$'\n\t'` | Restrict word splitting to newlines and tabs, preventing accidental word-splitting on spaces in filenames. |
| `shopt -s globstar` | Enable `**` recursive globbing. |
| `shopt -s nullglob` | Empty globs expand to nothing instead of the literal pattern. |

The `-u` flag is especially valuable for catching typos like `$BUCKET_NMAE`
before they expand to empty strings and trigger destructive globs.

### 2. Mandatory and optional variable validation

Fail fast on required inputs using parameter expansion with the `:?` operator,
and provide defaults for optional values:

```bash
DEPLOY_DIR="${DEPLOY_DIR:?ERROR: DEPLOY_DIR not set}"

LOG_LEVEL="${LOG_LEVEL:-info}"
readonly LOG_LEVEL
```

Apply `readonly` to computed or configured values so they cannot be silently
reassigned later in the script.

### 3. Dependency validation at startup

Validate that required commands exist before any work begins:

```bash
require_cmd() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "FATAL: Required command '$1' not found in PATH" >&2
        exit 1
    }
}
require_cmd curl
require_cmd jq
```

This surfaces an actionable message instead of an opaque "command not found"
mid-run, which is critical when the script is invoked by a CI runner with a
minimal environment.

### 4. Signal traps and cleanup

Register cleanup with a single function before allocating resources, and trap
it on `EXIT`, `INT`, and `TERM`:

```bash
CLEANUP_FILES=()
TMP_DIR="$(mktemp -d)"
CLEANUP_FILES+=("$TMP_DIR")

cleanup() {
    for f in "${CLEANUP_FILES[@]:-}"; do
        rm -rf "$f"
    done
}
trap cleanup EXIT INT TERM
```

Keeping temp files in a `CLEANUP_FILES` array and the temp directory in a
variable ensures the handler can remove them even when the script is killed by
a CI timeout. The `EXIT` signal fires on both normal completion and
error-triggered exits, making it the right hook for cleanup that must always
run.

### 5. Process substitution

Process substitution replaces a named pipe with a file descriptor, letting a
command's output feed into another command's stdin or file-argument slot
without an intermediate pipeline:

```bash
# Compare two remote files without temporary files
diff <(curl -sSL "$url_a") <(curl -sSL "$url_b")

# Feed sorted data into a read loop
while read -r line; do
    echo "record: $line"
done < <(sort "$data_file")
```

The `<(...)` form redirects a command's stdout to a `/dev/fd/NN` path and
`>(...)` redirects stdin. Because the substituted command runs in a subshell,
variable assignments inside it do not escape to the parent shell. This is
preferable to temporary files when the intermediate result is large or when the
upstream command writes to a non-seekable pipe.

### 6. Coprocess patterns

A coprocess (`coproc`) launches a background command with its stdin and stdout
connected to file descriptors stored in the `COPROC` array, enabling
bidirectional communication without managing pipes manually:

```bash
# Start a persistent JSON normalizer
coproc jq -c '.'

# Send input and close the write end so jq sees EOF and flushes output
echo '{"name":"app","status":"ok"}' >&"${COPROC[1]}"
exec {COPROC[1]}>&-

# Read the response
read -r response <&"${COPROC[0]}"
echo "$response"   # {"name": "app", "status": "ok"}

# Close the read end
exec {COPROC[0]}<&-
```

`${COPROC[1]}` is the write end (stdin of the coprocess) and
`${COPROC[0]}` is the read end (stdout). Closing the write end signals EOF to
the coprocess so it can produce output; keeping it open causes `read` to block
because many processors (including `jq`) buffer until EOF. This pattern suits
scripts that must make many small queries to a long-lived process — a language
server, a JSON transform engine, or an interactive REPL — avoiding the
fork/exec overhead of spawning it on every call. Always close both
descriptors when done to avoid leaked file descriptors.

### 7. Idempotency guard

Before performing a state-changing operation, test whether the current state
already matches the desired state:

```bash
deploy_config() {
    local source="$1" target="$2"
    if [[ ! -f "$target" ]] || ! diff -q "$source" "$target" >/dev/null; then
        install -m 0644 "$source" "$target"
        systemctl reload my-service
    fi
}
```

When the files are identical the function is a no-op; only on drift does it
install and reload. Repeated runs become safe, which is essential for
configuration drift correction in automated pipelines.

### 8. Testing and validation

Static analysis catches a class of errors that runtime testing cannot. Run
ShellCheck with error-level severity as a minimum gate:

```bash
shellcheck -S error -s bash "$script"
```

Pair static analysis with integration tests. A minimal `bats-core` suite
validates behavioral expectations:

```bash
#!/usr/bin/env bats

@test "script exits non-zero when DEPLOY_DIR is unset" {
    run "$script"
    [ "$status" -ne 0 ]
}
```

## Verify

```bash
# 1. Static analysis gate
shellcheck -S error -s bash production-script.sh

# 2. Runtime smoke test
bash production-script.sh

# 3. Integration tests
bats test/
```

## Common errors

- **`set -e` inside conditionals**: The `-e` flag is suspended inside `if`,
  `while`, `&&`, and `||` contexts. Commands that are expected to fail must use
  explicit `if`/`||` checks rather than relying on `set -e` to catch them.

- **Cron minimal environment**: Cron runs with a stripped `PATH`. Always set
  `PATH` at the top of cron-invoked scripts and use absolute paths for system
  commands.

- **`local var=$(cmd)` masks failures**: Under `set -e`, the `local`
  declaration itself succeeds even if `cmd` fails, so the script continues
  silently. Assign on a separate line when the exit status matters:
  `local var; var=$(cmd)`.

- **Parsing `ls` output**: Filenames with spaces or newlines break `ls`-based
  loops. Use `find -print0` with `read -d ''` instead.

- **`eval` with untrusted input**: Avoid `eval` entirely; build arguments as
  arrays and pass them directly.

## References

- Bash scripting patterns and pitfalls (strict mode, traps, idempotency,
  dependency validation, ShellCheck/bats-core):
  https://khimananda.com/blog/bash-scripting-for-devops-patterns-and-pitfalls
- Bash 5.3 release and patch history:
  https://cgit.git.savannah.gnu.org/cgit/bash.git/log
