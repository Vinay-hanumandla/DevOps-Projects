---
last_verified: 2026-09-24
tool_version: "5.3"
sources: []
---

# Bash 5.3 reference: nameref, coproc, and advanced process substitution

## Purpose

Bash 5.3 introduces and stabilizes three language features that change how scripts handle variable indirection, concurrent subprocess communication, and in-process command substitution. This reference documents `declare -n` namerefs with the 5.3 length-expansion fix, the `coproc` keyword with `MULTIPLE_COPROCS` enabled by default, and the new `${ command; }` / `${|command;}` substitution forms that avoid fork overhead.

## When to use

Consult this reference when designing functions that must mutate caller-scoped variables by name (`declare -n`), when building interactive filters or REPLs that stream data through long-lived coprocesses (`coproc`), or when optimizing hot loops that currently pay fork-and-pipe costs for `$(...)` substitutions (`${ ...; }`). Each feature is available only on Bash 5.3+; scripts targeting older releases must not use them unguarded.

## Prerequisites

- Bash 5.3 or later (`bash --version` reports 5.3.x).
- Familiarity with Bash scoping rules, file descriptors, and command substitution semantics.
- For coprocess examples: a POSIX environment with `/dev/fd` or `/proc/self/fd` support.

## Nameref: indirect variable references with `declare -n`

### Overview

A nameref is a variable that acts as an alias for another variable. Assignments to, reads from, and attribute changes on the nameref affect the referenced variable. Created with `declare -n ref=target` or `local -n ref=target`.

### Syntax

```bash
declare -n ref=variable_name
local -n ref=variable_name       # inside functions, scoped to function
declare -ng ref=array[index]     # nameref to array element (5.3+)
```

### Basic example

```bash
set_env() {
  local -n target=$1
  target="production"
}

var=""
set_env var
echo "$var"   # production
```

### Array element namerefs (5.3 fix)

Bash 5.3 corrects `${#ref}` length expansion when `ref` is a nameref to an array element created with `declare -ng`. Earlier versions returned `0`.

```bash
items=(alpha beta gamma)
declare -ng ref=items[1]
echo "${#ref}"   # 4 (length of "beta") — 5.3+; 0 on 5.2 and earlier
```

### Attributes and unset behavior

- `declare -p ref` shows the nameref declaration, not the target's value.
- `unset -n ref` removes the nameref binding; `unset ref` unsets the target variable.
- Array variables cannot be given the nameref attribute, but namerefs can reference arrays and array elements.
- In a `for` loop, a nameref control variable iterates over variable names: `for ref in var1 var2; do ...`.

### Common errors

**Length expansion returns 0 on array-element namerefs** — Pre-5.3 shells mishandle `${#ref}` when `ref` points to `array[index]`. Upgrade or avoid the pattern on older Bash.

**Nameref loops in functions** — If a function creates `local -n ref=$1` and the caller passes the same variable name, the nameref refers to itself. Validate input or use a different parameter name.

**Global leakage with `declare -n` outside functions** — A top-level `declare -n` creates a global nameref. Prefer `local -n` inside functions to limit scope.

## Coproc: bidirectional background processes

### Overview

`coproc NAME { command; }` starts `command` as a background job with two pipes: `NAME[0]` (read end, command's stdout) and `NAME[1]` (write end, command's stdin). The coprocess PID is in `NAME_PID`.

### MULTIPLE_COPROCS (5.3 default)

Bash 5.3 enables `MULTIPLE_COPROCS` by default. Multiple concurrent coprocesses are now supported without compile-time flags. Each coprocess gets a unique name; anonymous coprocesses (`coproc { ... }`) use `COPROC` as the array name.

### Basic example

```bash
coproc SORTER { sort; }
echo -e "delta\nalpha\nepsilon" >&${SORTER[1]}
exec {SORTER[1]}>&-          # close writer to signal EOF
cat <&${SORTER[0]}           # alpha, delta, epsilon
wait ${SORTER_PID}
```

### Managing multiple coprocesses

```bash
coproc READER { cat; }
coproc WRITER { tr 'a-z' 'A-Z'; }

# Pipe READER stdout -> WRITER stdin -> capture WRITER stdout
while IFS= read -r line <&${READER[0]}; do
  echo "$line" >&${WRITER[1]}
done
exec {WRITER[1]}>&-
cat <&${WRITER[0]}
wait ${READER_PID} ${WRITER_PID}
```

### File descriptor management

- Always close the write end (`exec {FD}>&-`) when done sending input; otherwise the coprocess blocks on read.
- Read from the read end until EOF; `wait` reaps the coprocess and cleans up pipes.
- `coproc` names must be valid shell identifiers. Anonymous coprocesses overwrite `COPROC` and `COPROC_PID`.

### Common errors

**Script hangs on coprocess read** — Forgot to close the write FD. The coprocess never sees EOF. Add `exec {COPROC[1]}>&-` after the last write.

**`bash: coproc: NAME: coprocess already exists`** — Reusing a coproc name without waiting for the previous one. Use unique names or `wait $NAME_PID` before restarting.

**File descriptor leakage in loops** — Each `coproc` allocates two FDs. In long-running loops, close both ends explicitly: `exec {READ[0]}<&- {READ[1]}>&-`.

## Advanced process substitution: `${ command; }` and `${|command;}`

### Overview

Bash 5.3 adds two in-process command substitution forms that execute in the current shell context instead of forking a subshell. This avoids fork/pipe overhead and preserves shell state changes (variable assignments, `trap` effects, `set` options) made inside the substitution.

### Two forms

| Form | Output handling | Use case |
|------|----------------|----------|
| `${ command; }` | Captures stdout into the expansion result | Drop-in for `$(command)` when fork avoidance matters |
| `${|command;}` | Leaves stdout in `REPLY`; expansion yields empty string | Side-effect commands where return value is in `REPLY` |

### Syntax rules

- The command list must end with `;` or `&` before the closing `}`.
- Redirections apply to the current shell, not a subshell.
- Exit status of the command list becomes the expansion's exit status.
- `break`, `continue`, `return`, `exit` inside `${ ...; }` affect the enclosing context.

### Performance comparison

```bash
# Subshell substitution (fork + pipe)
time for i in {1..1000}; do result=$(echo "$i"); done

# In-process substitution (no fork)
time for i in {1..1000}; do result=${ echo "$i"; }; done
```

The in-process form is significantly faster in tight loops and on resource-constrained systems.

### State preservation example

```bash
counter=0
increment() { ((counter++)); echo "$counter"; }

# Subshell: counter stays 0
for _ in {1..3}; do result=$(increment); done
echo "subshell: $counter"   # 0

# In-process: counter increments
for _ in {1..3}; do result=${ increment; }; done
echo "in-process: $counter" # 3
```

### REPLY form for streaming

```bash
while IFS= read -r line; do
  ${| sed 's/error/ERROR/'; }
  printf '%s\n' "$REPLY"
done < logfile
```

Each iteration writes the transformed line to `REPLY` without fork overhead.

### Common errors

**Syntax error: missing `;` before `}`** — The command list must terminate with `;` or `&`. `${ echo hi }` fails; `${ echo hi; }` works.

**Unexpected variable mutation** — Since `${ ...; }` runs in the current shell, assignments inside leak out. This is intentional for stateful patterns but surprising if treating it as a pure `$(...)` replacement.

**`REPLY` clobbering** — The `${| ...; }` form overwrites `REPLY`. Save it if the outer scope uses `REPLY`.

**Not a general `$(...)` replacement** — Use only when fork avoidance or state preservation is needed. Regular command substitution is clearer for simple cases.

## Associative arrays (cross-reference)

Bash 5.3 tightens duplicate-key assignment semantics (last value wins) and makes `declare -p` output round-trip cleanly through `eval`. See `bash-5.3-deep-dive.md` for the full treatment.

```bash
declare -A env=(
  [prod]=us-east-1
  [stage]=us-west-2
  [prod]=eu-west-1   # last wins
)
serialized=$(declare -p env)
eval "$serialized"
echo "${env[prod]}"   # eu-west-1
```

## Verify

1. Confirm Bash version: `bash --version | head -1` shows `5.3.x`.
2. Nameref length fix: `b=(x y z); declare -ng r=b[1]; [[ ${#r} -eq 1 ]] && echo ok`.
3. Multiple coprocesses: start two named `coproc` instances; both should run concurrently without "coprocess already exists" error.
4. In-process substitution: `x=0; ${ x=1; }; [[ $x -eq 1 ]] && echo ok`.
5. REPLY form: `${| echo hello; }; [[ $REPLY == hello ]] && echo ok`.

## Common errors summary

| Feature | Error | Cause | Fix |
|---------|-------|-------|-----|
| nameref | `${#ref}` = 0 on array element | Pre-5.3 bug | Upgrade to 5.3+ or use `${#array[index]}` directly |
| nameref | Self-reference loop | Caller passes same name as `local -n` param | Validate or rename parameter |
| coproc | Hang on read | Write FD not closed | `exec {COPROC[1]}>&-` after last write |
| coproc | "coprocess already exists" | Name reuse without wait | Use unique names or `wait $NAME_PID` |
| `${ ...; }` | Syntax error | Missing `;` before `}` | Terminate command list with `;` |
| `${ ...; }` | Silent state leak | Assignments inside affect outer scope | Intentional; document or avoid if unwanted |

