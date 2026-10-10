---
last_verified: 2026-10-10
tool_version: n/a
---

# Bash production runbook: strict-mode guardrails, PIPESTATUS telemetry, and ShellCheck CI gate

## Purpose

A production runbook for catching the Bash failures that exit-zero pipelines hide:
a stage in the middle of a pipe fails while the last command succeeds, and the
script — or the CI job — reports success. This doc covers three layers: the
strict-mode header that makes failures fatal, PIPESTATUS telemetry that records
the exit status of every pipeline stage, and a ShellCheck CI gate that rejects
scripts with static-analysis findings before they run.

The strict-mode header and trap-based cleanup are covered in depth in the
sibling docs
[production-reference-patterns](production-reference-patterns.md) and
[strict-mode-trap-patterns](strict-mode-trap-patterns.md); the first step below
states the baseline briefly and the rest of this runbook is new ground —
PIPESTATUS capture patterns and the CI gate.

## When to use

Apply this runbook when authoring or auditing Bash scripts that:

- Run in CI/CD pipelines where a silent intermediate failure masks a
  deployment or data regression.
- Chain two or more stages with pipes (`extract | transform | load`), where
  only the last stage's status reaches `$?`.
- Must present static-analysis evidence at review time via a CI gate.

Scripts that are single commands with no pipes need only the step-1 baseline;
everything from step 2 on is for piped workflows.

## Prerequisites

- A Bash shell available as `bash` on the authoring machine and on the CI
  runner (confirm both resolve with `command -v bash`).
- ShellCheck installed and on `PATH` wherever the gate runs
  (`command -v shellcheck`).
- A CI system that fails a job when a step exits non-zero.
- `jq` on any host that emits or consumes the structured telemetry in step 4.

## Steps

### 1. Strict-mode baseline

Start every production script with the fail-fast header. The option-by-option
rationale, variable-validation (`:?` with `readonly`), dependency-guard, and
trap-handler patterns are documented in
[production-reference-patterns](production-reference-patterns.md) and
[strict-mode-trap-patterns](strict-mode-trap-patterns.md); the canonical
header is:

```bash
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
```

With `pipefail` active, a pipeline's status is non-zero when any stage fails,
which is what makes the PIPESTATUS telemetry below meaningful: without
`pipefail`, `$?` after a pipe still reports only the last stage, and with it,
the job at least fails — PIPESTATUS then tells you *which* stage failed.

### 2. Capture PIPESTATUS immediately after every critical pipeline

The shell exposes one status per pipeline stage in the `PIPESTATUS` array, but
the array is overwritten by the very next command — including an `echo` used
for debugging. Copy it on the line directly after the pipeline:

```bash
extract_records "$input_file" | normalize_records | sort -u > "$output_file"
statuses=("${PIPESTATUS[@]}")
```

Check each element before doing anything else with the output file, since a
mid-pipe failure can leave a truncated but non-empty result behind:

```bash
for i in "${!statuses[@]}"; do
    if [[ ${statuses[i]} -ne 0 ]]; then
        echo "FATAL: pipeline stage $i exited ${statuses[i]}; discarding $output_file" >&2
        rm -f "$output_file"
        exit 1
    fi
done
```

Deleting the partial output matters: downstream steps keyed on file existence
would otherwise consume corrupt data on retry.

### 3. Report per-stage failures with a capture-then-pass helper

A helper cannot read the caller's `PIPESTATUS` directly: invoking a function —
like running any other command — replaces the array with the status of the
call setup itself (verified: a function entered after `true | false | true`
sees a single `0`, not `0 1 0`). The working pattern is to copy the array at
the call site and pass the values as ordinary arguments:

```bash
report_stages() {
    local stage_name="$1"
    shift
    local code
    local pos=0
    local failed=0
    for code in "$@"; do
        if [[ $code -ne 0 ]]; then
            echo "ERROR: stage '$stage_name', pipe position $pos exited $code" >&2
            failed=1
        fi
        pos=$((pos + 1))
    done
    return "$failed"
}
```

Call-site discipline — copy first, then report, then decide:

```bash
extract_records "$input_file" | normalize_records | sort -u > "$output_file"
stages=("${PIPESTATUS[@]}")
report_stages "normalize" "${stages[@]}" || { rm -f "$output_file"; exit 1; }
```

The `rm -f` before exit matters for the same reason as in step 2: a failed
middle stage can leave a truncated output file that downstream steps would
otherwise treat as valid input on retry.

### 4. Emit structured telemetry for log aggregation

For jobs whose logs feed a collector, emit one record per pipeline execution
with the stage name and the full status array:

```bash
emit_stages() {
    local stage="$1"
    shift
    local codes_json
    if [[ $# -eq 0 ]]; then
        codes_json='[]'
    else
        codes_json=$(printf '%s\n' "$@" | jq -R . | jq -s 'map(tonumber)')
    fi
    jq -n \
        --arg stage "$stage" \
        --argjson pipestatus "$codes_json" \
        '{stage: $stage, pipestatus: $pipestatus}'
}
```

Usage with the array captured at the call site (same constraint as step 3 —
the helper must receive the values, it cannot read them itself):

```bash
extract_records "$input_file" | normalize_records | sort -u > "$output_file"
stages=("${PIPESTATUS[@]}")
report_stages "normalize" "${stages[@]}" || { rm -f "$output_file"; exit 1; }
emit_stages "normalize" "${stages[@]}"
```

Example records (one healthy run, one with a failed middle stage):

```json
{"stage":"normalize","pipestatus":[0,0,0]}
{"stage":"normalize","pipestatus":[0,1,0]}
```

Alert on any non-zero element of `pipestatus`. The middle-stage failure in the
second record is exactly the case `$?` alone would miss when the final `sort`
succeeds without `pipefail`, and the case `pipefail` alone would report without
identifying.

### 5. Mind PIPESTATUS scope: function calls, subshells, and command substitution

Three scope rules govern where the array is valid:

- **A function call resets it.** A function entered immediately after a
  pipeline sees only the call's own single-element status, not the pipeline's
  stages. Always copy to a named array first and pass the values as arguments
  (the pattern used in steps 3 and 4).
- **A subshell keeps its own copy.** In `output=$(cmd1 | cmd2)`, only the
  subshell sees the two-element array; the parent sees a single exit status
  for the whole substitution. When per-stage detail matters, run the pipeline
  in the current shell and redirect to a file instead of capturing into a
  variable:

```bash
cmd1 | cmd2 > "$tmp_out"
stages=("${PIPESTATUS[@]}")
output=$(<"$tmp_out")
```

The same scope rule applies to pipelines inside `while read` loops fed by a
pipe (the loop body runs in a subshell) and to `tee`-based logging: `cmd |
tee log | next` adds `tee`'s own status as a middle element, so expect one more
entry than the logical stage count and treat a `tee` failure as a real signal
(the log is incomplete).

### 6. Gate every change on ShellCheck in CI

Run ShellCheck as a mandatory step with the severity threshold and shell
dialect set explicitly, so results do not depend on a contributor's local
defaults:

```bash
shellcheck -S error -s bash scripts/*.sh
```

Severity behavior, least to most strict:

| Flag | Gate behavior |
|---|---|
| `-S error` | Fail only on error-level findings; the recommended production default. |
| `-S warning` | Additionally fail on warnings; adopt once the error gate is green. |
| `-S info` / `-S style` | Fail on informational and stylistic findings; maximum strictness for mature repos. |

The `-s bash` dialect flag pins the parse to Bash semantics so Bash-only
constructs are not flagged as portability warnings.

A minimal CI job shape (runner labels and checkout actions per the platform's
current docs; pin action revisions per org policy):

```yaml
jobs:
  shellcheck:
    steps:
      - name: Check out sources
        uses: actions/checkout  # pin revision per org policy
      - name: Run ShellCheck gate
        run: |
          find . -name '*.sh' -type f -exec shellcheck -S error -s bash {} +
```

Keep the gate on the default severity until the tree is clean, then ratchet to
`warning`; ratcheting before the backlog is fixed trains contributors to ignore
a red gate.

### 7. Policy for inline exclusions

Some findings are intentional (e.g. deliberate word splitting when expanding
an array). Suppress them inline with a justification comment, never silently:

```bash
# shellcheck disable=SC2086  # Intentional: splitting validated flag words here.
deploy_flags=($EXTRA_FLAGS)
```

Rules for exclusions:

- Every `disable` carries a same-line or preceding-line comment stating why
  the construct is safe.
- Never disable a rule repository-wide in the CI invocation to silence one
  script; scope the exception to the line that needs it.
- Re-audit open exclusions on a cadence (e.g. quarterly): remove any whose
  justification no longer holds and fix the code instead.

### 8. Smoke-test scripts in CI with PIPESTATUS assertions

Complement the static gate with a runtime smoke step that runs each script in a
safe mode and asserts on the pipeline status directly:

```bash
for script in scripts/*.sh; do
    bash -n "$script" || { echo "FAIL: syntax $script"; exit 1; }
    bash "$script" --help >/dev/null 2>&1
    echo "smoke $script exited $?"
done
```

Where a script's main flow is itself a pipeline, assert the middle stages in a
test harness by sourcing the script's functions and checking the recorded
array, rather than eyeballing log output.

## Verify

```bash
# 1. Static gate passes on every script in the tree.
find . -name '*.sh' -type f -exec shellcheck -S error -s bash {} +

# 2. Syntax check passes.
bash -n scripts/*.sh

# 3. PIPESTATUS reports a known failing middle stage.
bash -c 'true | false | true; echo "${PIPESTATUS[*]}"'
# Expect: "0 1 0"

# 4. Helpers report the failing element from a captured array.
bash -c 'report_stages() { local n="$1"; shift; local c; local p=0; for c in "$@"; do [[ $c -ne 0 ]] && echo "ERROR: $n position $p exited $c"; p=$((p+1)); done; }; true | false | true; s=("${PIPESTATUS[@]}"); report_stages "selftest" "${s[@]}"'
# Expect: "ERROR: selftest position 1 exited 1".

# 5. Partial output is discarded on stage failure.
bash -c 'false | sort -u > /tmp/pipestatus-selftest-out.txt; s=("${PIPESTATUS[@]}"); [[ ${s[0]} -ne 0 ]] && rm -f /tmp/pipestatus-selftest-out.txt; [[ ! -e /tmp/pipestatus-selftest-out.txt ]] && echo "partial discarded"'
# Expect: "partial discarded".
```

## Rollback

If enforcing this runbook breaks existing workflows:

1. **Relax one guard at a time, scoped to the failing section.** Prefer
   temporarily downgrading the ShellCheck severity for the affected path over
   disabling the gate, and record the downgrade with an owner and a target
   date for re-tightening.
2. **Convert a fatal PIPESTATUS check into a warning** while the upstream
   stage is fixed: log the non-zero element and continue, but keep emitting
   the telemetry record so the failure stays visible in the collector.
3. **Narrow an inline exclusion rather than widening it.** If a
   `disable` comment starts covering more lines than intended, move it to the
   single line that needs it instead of adding broader suppressions.
4. **Full revert** — restore the previous script header from version history
   and re-open the gate findings as tracked work rather than leaving the tree
   red.

## Common errors

- **Reading PIPESTATUS one command too late.** Any intervening command —
  even `echo`, and including a call to a reporting helper — replaces the
  array. Copy it on the line directly after the pipeline and pass the values
  as arguments (steps 3–4).
- **Expecting per-stage detail from a command substitution.** The parent
  shell sees only the substitution's overall status; run the pipeline in the
  current shell per step 5 when stage detail matters.
- **Forgetting `tee` occupies a PIPESTATUS slot.** `a | tee log | b`
  yields three entries; asserting a two-element expectation fails spuriously.
- **Local declaration masking a failure.** `local out=$(cmd)` reports the
  status of `local`, not `cmd`. Split declaration and assignment when the
  status matters: `local out; out=$(cmd)`.
- **`set -e` suspended in conditionals.** Commands inside `if`, `while`,
  `&&`, and `||` do not trigger immediate exit; use explicit status checks
  there.
- **Exclusion without justification.** A bare `disable` with no comment
  rots: nobody can tell intent from suppression at review time. Require the
  comment per step 7.

## References

- Bash manual: the `set` builtin (especially `pipefail`), the `PIPESTATUS`
  array variable, and the `shopt` options.
- ShellCheck rule catalog: per-rule descriptions and rationale for each
  diagnostic code.
- The `jq` manual: the `--arg` / `--argjson` invocation and the `map`
  filter used by the telemetry helper.
- Sibling docs in this directory: the strict-mode header, variable
  validation, dependency guard, trap handler, process-substitution, coprocess,
  and idempotency patterns.
