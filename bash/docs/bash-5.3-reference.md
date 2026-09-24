---
last_verified: 2026-09-24
tool_version: n/a
sources: []
---

# Bash 5.3 reference: associative arrays, nameref, coproc, and advanced process substitution

## Purpose

Bash 5.3 introduces corrections and new capabilities in four areas that affect everyday scripting: associative array behavior, name-reference variables (`nameref`), coprocess handling, and process substitution syntax. This reference covers each change, demonstrates the corrected or new behavior, and notes compatibility constraints for teams running older releases. For command-substitution syntax (`${ cmd; }`, `${|cmd;}`), `GLOBSORT`, `MULTIPLE_COPROCS` default-on, and `test` builtin changes, see the companion [Bash 5.3 migration guide](bash-5.3-migration-guide.md).

## When to use

Consult this reference when:
- A script uses associative arrays and needs predictable `declare -p` round-tripping or duplicate-key semantics.
- You need to pass array or variable names by reference between functions using `declare -n` (nameref).
- A coprocess-based pipeline requires multiple concurrent coprocesses or reliable cleanup.
- You are evaluating the new `${ cmd; }` in-process substitution form for performance-critical loops that modify shell state.

The fixes and features below apply at the language level; no external tooling changes are required.

## Prerequisites

- Bash 5.3 or later for all features described here.
- A POSIX-compatible terminal for running the examples.
- For cross-platform scripts, guard each feature with a version check: `[[ ${BASH_VERSINFO[0]} -eq 5 && ${BASH_VERSINFO[1]} -ge 3 ]] || { echo "Bash 5.3+ required" >&2; exit 1; }`.

## Associative array improvements

### Duplicate-key assignment semantics

Bash has supported associative arrays since version 4.0. Bash 5.3 tightens the behavior when the same key is assigned more than once in a single compound assignment. The last value wins consistently, and `declare -p` produces output that evaluates back to an identical array without corruption.

```bash
declare -A env
env=(
  [production]=us-east-1
  [staging]=us-west-2
  [production]=eu-west-1   # last assignment wins
)
declare -p env
# Output: declare -A env='([production]="eu-west-1" [staging]="us-west-2" )'
```

### `declare -p` output consistency

The formatted output from `declare -p` for associative arrays now round-trips cleanly through `eval`, which matters for serialization, test harnesses, and configuration passing.

```bash
serialized=$(declare -p env)
eval "$serialized"
echo "${env[production]}"   # eu-west-1
```

Empty-string values are preserved in the round-trip:

```bash
declare -A flags
flags[verbose]=
flags[debug]=1
serialized=$(declare -p flags)
eval "$serialized"
[[ -v flags[verbose] && -z ${flags[verbose]} ]] && echo "empty value preserved"
```

### Nameref array-element length fix (`declare -ng`)

Bash 5.3 corrects a long-standing issue where `declare -n` (nameref) could not reliably reference an associative array element by key, and `${#nameref[@]}` did not report the element count of the referenced array. The `declare -ng` form (global nameref) now permits a nameref to point to an associative array, and `${#ref[@]}` expands to the number of elements in the referenced array.

```bash
declare -A config=( [host]="api.example.com" [port]=443 [timeout]=30 )
declare -ng ref=config        # global nameref to associative array
echo "Elements: ${#ref[@]}"   # 3
echo "Host: ${ref[host]}"      # api.example.com
ref[port]=8443                # modifies original
echo "${config[port]}"        # 8443
```

> **Compatibility note:** On Bash < 5.3, `declare -ng` is accepted but `${#ref[@]}` expands to `1` (the nameref itself) rather than the referenced array's element count. Scripts depending on element-count semantics should guard with a version check or avoid nameref-to-associative-array patterns on older shells.

## Coprocess enhancements

### `MULTIPLE_COPROCS` default-on

Bash 4.x allowed only a single active coprocess at a time; starting a second coprocess terminated the first. Bash 5.3 enables `MULTIPLE_COPROCS` by default, permitting multiple concurrent coprocesses. Each coprocess receives a unique name and file descriptors (`COPROC[0]`, `COPROC[1]`, `COPROC_PID`).

```bash
coproc SORTER { sort; }
coproc FILTER { grep -v '^#'; }

printf 'zebra\napple\n#comment\nbanana\n' >&"${SORTER[1]}"
exec {SORTER[1]}>&-
printf '%s\n' "${SORTER[0]}"  # sorted, comment removed by second coproc if piped
```

The coprocess array variables (`COPROC`, `COPROC_PID`) are set for the most recently started coprocess. Access earlier coprocesses by the name given in the `coproc NAME { ... }` syntax (e.g., `${SORTER[0]}`).

### Coprocess cleanup and `wait`

Bash 5.3 improves `wait` behavior with coprocesses: `wait $COPROC_PID` (or `wait %NAME`) reliably reaps the coprocess and makes its exit status available in `$?`. The `COPROC` array is unset after `wait` returns.

```bash
coproc WORKER { sleep 0.1; echo "done"; }
read -u "${WORKER[0]}" line
wait "$WORKER_PID"
echo "Exit status: $?"   # 0
```

> **Compatibility note:** `MULTIPLE_COPROCS` is on by default in 5.3+. On Bash 4.x or 5.2, only one coprocess can be active; starting a second kills the first. Scripts requiring multiple concurrent coprocesses must either require 5.3+ or serialize coprocess usage.

## Advanced process substitution

### In-process substitution: `${ cmd; }` and `${|cmd;}`

Bash 5.3 introduces two new command-substitution forms that execute in the current shell context instead of forking a subshell. This avoids the performance cost of fork/exec and allows the command to modify shell state (variables, options, traps).

```bash
# Captures stdout; failures propagate the inner exit status.
result=${ grep -c "^error" app.log; }

# Leaves output in REPLY; useful for side-effect commands.
${ printf '%s\n' "$var" | sed 's/ /_/g'; }
echo "$REPLY"
```

- `${ cmd; }` captures stdout (like `$(cmd)`) but runs in the current shell.
- `${|cmd;}` discards stdout, leaves the command's output in `REPLY`, and is intended for commands whose return value is used indirectly.

> **Cross-reference:** For migration guidance on replacing legacy `` `cmd` `` and `$(cmd)` with in-process substitution, see the [Bash 5.3 migration guide](bash-5.3-migration-guide.md#1-adopt-the-new-command-substitution-syntax).

### Interaction with `set -e` and `inherit_errexit`

When `inherit_errexit` is enabled (default on in Bash 5.x), a failure inside `${ cmd; }` propagates immediately under `set -e`, just as if the command ran directly. This differs from subshell `$(cmd)` where the failure is captured in the exit status of the substitution.

```bash
set -e
shopt -s inherit_errexit
result=${ false; }   # script aborts here
echo "unreachable"
```

Guard with `|| true` when the exit status is expected to be non-zero:

```bash
result=${ grep -q "pattern" file; } || true
```

## Verify

1. Run `bash --version | head -1` and confirm the version string shows 5.3 or later.
2. Execute each code block above in a Bash 5.3 shell; all commands should complete without error.
3. Confirm `MULTIPLE_COPROCS` is enabled by default: `shopt MULTIPLE_COPROCS` outputs `MULTIPLE_COPROCS on`.
4. Confirm the nameref element-count fix: `declare -A a=( [x]=1 [y]=2 ); declare -ng r=a; echo ${#r[@]}` should print `2`.
5. Confirm associative array `declare -p` round-trip preserves empty values.
6. Confirm in-process substitution modifies shell state: `x=0; ${ x=1; }; echo $x` prints `1`.

## Common errors

**`declare -ng` accepted but `${#ref[@]}` returns 1 on Bash < 5.3** — The nameref is created but element-count semantics are broken. Guard with `[[ ${BASH_VERSINFO[0]} -eq 5 && ${BASH_VERSINFO[1]} -ge 3 ]]` before relying on `${#ref[@]}`.

**`coproc` terminates previous coprocess on Bash < 5.3** — Only one coprocess can be active. Serialize usage or require Bash 5.3+.

**In-process substitution `${ cmd; }` aborts script under `set -e` when `cmd` fails** — Unlike `$(cmd)`, the failure is not contained. Use `|| true` when non-zero exit is acceptable.

**`REPLY` overwritten by subsequent `${|cmd;}`** — The `REPLY` variable is global; save it immediately if the value is needed later.

**Associative array key order is not insertion order** — `declare -p` prints keys in hash-table iteration order, which may differ from insertion order. Do not depend on key order for logic.

## References

- Bash 5.3 announcement (release and patch details): https://lists.gnu.org/archive/html/bash-announce/2025-07/msg00000.html
- Bash 5.3 patch archive: https://mirrors.ibiblio.org/gnu/bash/bash-5.3-patches/
- Bash manual (coprocesses): https://www.gnu.org/software/bash/manual/html_node/Coprocesses.html
- Bash manual (nameref): https://www.gnu.org/software/bash/manual/html_node/Shell-Builtin-Commands.html#index-declare
- Companion migration guide (command substitution, GLOBSORT, MULTIPLE_COPROCS, test builtin): bash-5.3-migration-guide.md