---
last_verified: 2026-10-09
tool_version: n/a
sources: []
---

# Bash production runbook: strict-mode guardrails, PIPESTATUS telemetry, and ShellCheck CI gate

## Purpose

A production runbook for hardening Bash scripts against the failure modes that
cause silent data corruption, undetected pipeline failures, and CI false
positives. This doc covers three complementary layers: shell option guardrails
that enforce fail-fast behavior at runtime, PIPESTATUS array telemetry that
surfaces the exit code of every pipeline component, and a ShellCheck CI gate
that catches static analysis violations before they reach runtime.

## When to use

Apply this runbook when authoring or auditing Bash scripts that:

- Run in CI/CD pipelines where silent failures mask deployment regressions
- Operate on infrastructure state where rollback is costly
- Process data pipelines where partial pipeline failure corrupts output
- Must pass compliance gates requiring static analysis evidence

This runbook assumes Bash 5.3 or later. Scripts targeting older Bash versions
should consult the migration guide for feature availability.

## Prerequisites

- Bash 5.3+ (`bash --version` reports 5.3.x)
- ShellCheck 0.9+ installed and in PATH
- CI system supporting exit-code-based gating (GitHub Actions, GitLab CI,
  Jenkins, Azure Pipelines)
- Optional: `bats-core` for runtime contract tests

## Steps

### 1. Strict-mode header guard

Start every production script with a header that enforces deterministic
behavior and eliminates the most common silent-failure classes:

```bash
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
shopt -s globstar nullglob failglob
```

| Option | Purpose | Failure mode prevented |
|---|---|---|
| `-e` | Exit immediately on non-zero exit | Script continues after command failure |
| `-u` | Treat unset variable expansion as error | Silent empty-string expansion (`$BUCKET_NMAE`) |
| `-o pipefail` | Pipeline fails on first non-zero component | Swallowed errors in `cmd1 \| cmd2 \| cmd3` |
| `IFS=$'\n\t'` | Restrict word splitting to newlines/tabs | Filename globbing on spaces in paths |
| `shopt -s globstar` | Enable `**` recursive globbing | Manual `find` workarounds |
| `shopt -s nullglob` | Empty globs expand to empty list | Literal pattern passed to downstream command |
| `shopt -s failglob` | Non-matching globs cause expansion error | Silent no-op on typo'd glob patterns |

**Note:** `failglob` is stricter than `nullglob` — it causes the script to exit
with an error when a glob matches nothing, catching typos like `*.yml` when
files use `.yaml`. Use `nullglob` when empty matches are valid (e.g., optional
config directories).

### 2. Mandatory and optional variable validation

Fail fast on required inputs using parameter expansion with the `:?` operator,
and pin computed values with `readonly`:

```bash
# Required — script exits with message if unset or empty
DEPLOY_ENV="${DEPLOY_ENV:?ERROR: DEPLOY_ENV must be set (prod|staging|dev)}"
ARTIFACT_BUCKET="${ARTIFACT_BUCKET:?ERROR: ARTIFACT_BUCKET not set}"

# Optional — default provided, then frozen
LOG_LEVEL="${LOG_LEVEL:-info}"
readonly LOG_LEVEL

RETRY_COUNT="${RETRY_COUNT:-3}"
readonly RETRY_COUNT
readonly DEPLOY_ENV
readonly ARTIFACT_BUCKET
```

Apply `readonly` to all configuration values after validation. This prevents
accidental reassignment in helper functions or sourced libraries.

### 3. Dependency validation at startup

Validate external commands before any work begins. This surfaces actionable
errors instead of opaque mid-run failures:

```bash
require_cmd() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "FATAL: Required command '$1' not found in PATH" >&2
        exit 127
    }
}

require_cmd aws
require_cmd jq
require_cmd kubectl
require_cmd shellcheck
```

Exit code `127` distinguishes "command not found" from other failures.

### 4. Signal traps and cleanup with inheritance safety

Register cleanup before allocating resources. Use `set +e` inside the handler
to prevent trap failures from masking the original exit code:

```bash
CLEANUP_FILES=()
TMP_DIR="$(mktemp -d)"
CLEANUP_FILES+=("$TMP_DIR")

cleanup() {
    local exit_code=$?
    set +e
    for f in "${CLEANUP_FILES[@]:-}"; do
        [[ -e "$f" ]] && rm -rf "$f"
    done
    exit "$exit_code"
}
trap cleanup EXIT INT TERM
```

The `EXIT` trap fires on both normal completion and error exits, guaranteeing
cleanup. Saving `$?` at handler entry preserves the original exit code.

### 5. PIPESTATUS telemetry for pipeline observability

Bash exposes the exit code of each pipeline component in the `PIPESTATUS`
array. Capture and log it immediately after every critical pipeline:

```bash
run_pipeline() {
    local stage_name="$1"
    shift
    "$@"
    local -a statuses=("${PIPESTATUS[@]}")
    local failed=0
    for i in "${!statuses[@]}"; do
        if [[ ${statuses[i]} -ne 0 ]]; then
            echo "ERROR: $stage_name stage $i exited ${statuses[i]}" >&2
            failed=1
        fi
    done
    return "$failed"
}

# Usage
run_pipeline "data-transform" \
    bash -c 'set -euo pipefail; cat "$1" | jq -c ".records[]" | sort -u' _ "$input_file" \
    | gzip -c > "$output_file.gz"
```

**Telemetry pattern for CI integration:** Emit structured JSON for log
aggregation:

```bash
emit_pipestatus() {
    local stage="$1"
    shift
    local -a codes=("${PIPESTATUS[@]}")
    local json
    json=$(jq -n \
        --arg stage "$stage" \
        --argjson codes "$(printf '%s\n' "${codes[@]}" | jq -R . | jq -s .)" \
        '{stage: $stage, pipestatus: $codes, timestamp: now}')
    echo "$json"
}

# In CI, pipe to log collector
run_pipeline "etl" cmd1 | cmd2 | cmd3
emit_pipestatus "etl" >&2
```

This produces:
```json
{"stage":"etl","pipestatus":[0,0,0],"timestamp":"2026-10-09T12:34:56Z"}
{"stage":"etl","pipestatus":[0,1,0],"timestamp":"2026-10-09T12:35:12Z"}
```

Alert on any non-zero element in `pipestatus` to catch partial failures.

### 6. ShellCheck CI gate

Integrate ShellCheck as a mandatory gate in CI. Configure severity and shell
dialect explicitly:

```yaml
# .github/workflows/shellcheck.yml
name: ShellCheck
on: [push, pull_request]
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install ShellCheck
        run: sudo apt-get update && sudo apt-get install -y shellcheck
      - name: Run ShellCheck
        run: |
          find . -name '*.sh' -type f | while read -r script; do
            shellcheck -S error -s bash "$script"
          done
```

**Severity levels:**

| Flag | Behavior | Recommended for |
|---|---|---|
| `-S error` | Exit non-zero on any error | Production gate (default) |
| `-S warning` | Exit non-zero on warnings | Hardened gate |
| `-S style` | Exit non-zero on style issues | Maximum strictness |

**Exclude patterns only with justification:**

```bash
# shellcheck disable=SC2086  # Intentional word splitting for array expansion
args=($UNQUOTED_VAR)
```

Document every `disable` with an inline comment explaining why the violation
is intentional and safe. Audit disabled rules quarterly.

### 7. Combined CI pipeline template

```yaml
# .github/workflows/bash-ci.yml
name: Bash CI
on: [push, pull_request]
jobs:
  static-analysis:
    name: ShellCheck
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run ShellCheck
        run: |
          find . -name '*.sh' -type f -exec shellcheck -S error -s bash {} +

  runtime-tests:
    name: Bats Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install Bats
        run: sudo apt-get update && sudo apt-get install -y bats
      - name: Run Tests
        run: bats test/

  integration:
    name: Integration Smoke
    runs-on: ubuntu-latest
    needs: [static-analysis, runtime-tests]
    steps:
      - uses: actions/checkout@v4
      - name: Run Scripts
        env:
          DEPLOY_ENV: test
          ARTIFACT_BUCKET: test-bucket
        run: |
          for script in scripts/*.sh; do
            bash "$script" --dry-run 2>&1 | tee "logs/$(basename "$script").log"
            if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
              echo "FAIL: $script exited ${PIPESTATUS[0]}"
              exit 1
            fi
          done
```

## Verify

```bash
# 1. Static analysis gate
shellcheck -S error -s bash scripts/*.sh

# 2. Syntax validation
bash -n scripts/*.sh

# 3. Runtime smoke test with PIPESTATUS capture
for script in scripts/*.sh; do
    bash "$script" --dry-run
    [[ ${PIPESTATUS[0]} -eq 0 ]] || { echo "FAIL: $script"; exit 1; }
done

# 4. Integration tests
bats test/

# 5. Verify PIPESTATUS telemetry emits on failure
bash -c 'false | true'
echo "PIPESTATUS: ${PIPESTATUS[*]}"  # Expect: "PIPESTATUS: 1 0"
```

## Rollback

If a strict-mode change breaks existing workflows:

1. **Temporarily relax a specific guard** — wrap the problematic section:
   ```bash
   set +u
   legacy_var="${UNSET_VAR:-default}"
   set -u
   ```
   Document with `# TODO: Remove when legacy_var migration complete (bash-041)`

2. **Revert `failglob` to `nullglob`** if glob typos are not the primary
   concern and empty matches are valid:
   ```bash
   shopt -u failglob
   shopt -s nullglob
   ```

3. **Disable specific ShellCheck rule** in CI config (not inline) for a
   transition period:
   ```yaml
   - name: Run ShellCheck
     run: |
       shellcheck -S error -s bash -e SC2086,SC2155 scripts/*.sh
   ```
   Track each exclusion in a `SHELLCHECK_EXCLUSIONS.md` with owner and target
   removal date.

4. **Full revert** — restore the previous script header from git history:
   ```bash
   git show HEAD:scripts/production-script.sh | head -20
   ```

## Common errors

- **`local var=$(cmd)` masks command failure** — Under `set -e`, the `local`
  declaration succeeds even if `cmd` fails. Fix: separate assignment:
  `local var; var=$(cmd)`

- **`set -e` suspended in conditionals** — Commands inside `if`, `while`,
  `&&`, `||` do not trigger `-e`. Use explicit checks:
  ```bash
  if ! critical_command; then
      handle_failure
  fi
  ```

- **Subshell `PIPESTATUS` loss** — `PIPESTATUS` is local to the shell that
  executed the pipeline. In `output=$(cmd1 | cmd2)`, the parent shell sees
  only the subshell's exit code. Fix: capture in the same shell:
  ```bash
  cmd1 | cmd2
  local -a ps=("${PIPESTATUS[@]}")
  ```

- **Cron `PATH` stripped** — Cron runs with minimal `PATH`. Always set
  `PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin` at
  script top or use absolute paths.

- **ShellCheck false positive on dynamic sourcing** — `source "$LIB_DIR/$mod.sh"`
  triggers SC1090. Fix: add `# shellcheck source=/dev/null` before the line
  or use a static include list.

- **`readonly` in subshells** — `readonly` variables cannot be modified even
  in subshells, but subshells inherit the readonly attribute. This is
  generally safe but can surprise when `local` is expected to shadow.

## References

- Bash manual — `set` builtin, `PIPESTATUS` variable, `shopt` options:
  https://www.gnu.org/software/bash/manual/bash.html
- ShellCheck wiki — rule descriptions and rationale:
  https://github.com/koalaman/shellcheck/wiki
- Bats-core documentation — test framework for Bash:
  https://bats-core.readthedocs.io/