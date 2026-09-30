#!/usr/bin/env bash
# last_verified: 2026-09-30 · Bash n/a
#
# retry-with-circuit-breaker.sh — retry wrapper with exponential backoff,
# a consecutive-failure circuit breaker, and structured key=value logging.
#
# Purpose:
#   Wrap any command so transient failures are retried with jittered
#   exponential backoff, and stop calling a dependency altogether once it
#   has failed often enough in a row. Without the breaker, a retry loop
#   against a down dependency turns one outage into a saturating pile of
#   requests; with it, the dependency is left alone long enough to recover.
#
# When to use:
#   CI steps and deploy wrappers polling an HTTP endpoint, an API client
#   calling a queue or registry, and any unattended job where "retry until
#   it works" without a ceiling would just delay the failure.
#
# Prerequisites:
#   bash, date, sleep, and an optional flock for state-file locking.
#   Without --state-dir the breaker lives in memory for the life of the
#   process, which is the right behaviour when each invocation is its own
#   short-lived wrapper.
#
# Steps:
#   1. ./retry-with-circuit-breaker.sh [options] -- <command> [args...]
#   2. Options: --attempts N, --base-delay MS, --max-delay MS,
#      --multiplier N, --breaker-threshold N, --reset-timeout S,
#      --state-dir DIR, --key NAME, --log-file FILE, --help.
#   3. Exit status: the command's own status, 75 if the breaker is open and
#      the call was rejected without running anything, 64 on usage error.
#
# Verify:
#   bash -n retry-with-circuit-breaker.sh
#   then run ShellCheck at warning severity on the same file
#   ./retry-with-circuit-breaker.sh --attempts 3 --base-delay 100 \
#       -- sh -c 'exit 0' && echo "command succeeded on first attempt"
#   ./retry-with-circuit-breaker.sh --attempts 2 --base-delay 50 \
#       -- sh -c 'exit 3'; echo "exit status $?"
#
# Common errors:
#   - Every attempt "fails" with status 70 for transient problems: pick a
#     single failure code and document it, otherwise a genuine usage error
#     is retried as if it were a blip.
#   - Breaker never opens: --breaker-threshold is above --attempts, so a run
#     gives up before it can record enough consecutive failures.
#   - "Text file busy" or truncated state: concurrent wrappers sharing a
#     --state-dir without flock available. Install flock or give each
#     concurrent caller its own --key.

set -euo pipefail

# --- defaults ---------------------------------------------------------------

ATTEMPTS=5
BASE_DELAY_MS=200
MAX_DELAY_MS=30000
MULTIPLIER=2
BREAKER_THRESHOLD=5
RESET_TIMEOUT_S=30
STATE_DIR=""
BREAKER_KEY="default"
LOG_FILE=""

# Exit code used when the breaker is open. 75 (EX_TEMPFAIL) matches the
# convention of "the request was not made; come back later".
readonly EXIT_CIRCUIT_OPEN=75

# --- logging ----------------------------------------------------------------

# Escape a value so it survives being embedded in a key=value log line.
quote_value() {
  local v="$1"
  v="${v//\\/\\\\}"
  v="${v//\"/\\\"}"
  printf '"%s"' "$v"
}

# One structured event per line: ts, level, event, then caller-supplied pairs.
log_event() {
  local level="$1" event="$2"
  shift 2
  local ts line pair
  ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  line="ts=${ts} level=${level} event=${event}"
  for pair in "$@"; do
    line+=" ${pair}"
  done
  if [[ -n "$LOG_FILE" ]]; then
    printf '%s\n' "$line" >>"$LOG_FILE"
  fi
  printf '%s\n' "$line" >&2
}

die() {
  log_event error fatal "$@"
  exit 64
}

# --- argument parsing -------------------------------------------------------

print_usage() {
  cat <<'USAGE'
Usage: retry-with-circuit-breaker.sh [options] -- <command> [args...]

Retries COMMAND with jittered exponential backoff and refuses to call it
while the circuit breaker is open.

Options:
  --attempts N            total attempts including the first (default 5)
  --base-delay MS         first backoff delay in milliseconds (default 200)
  --max-delay MS          ceiling for a single backoff delay (default 30000)
  --multiplier N          integer backoff growth factor (default 2)
  --breaker-threshold N   consecutive failures that open the breaker (default 5)
  --reset-timeout S       seconds an open breaker waits before half-opening
  --state-dir DIR         persist breaker state here so it survives the process
  --key NAME              breaker state name inside --state-dir (default default)
  --log-file FILE         append log lines here as well as to stderr
  -h, --help              show this help

Exit status: the command's status, or 75 if the breaker is open.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --attempts)          ATTEMPTS="${2:?--attempts needs a value}"; shift 2 ;;
    --base-delay)        BASE_DELAY_MS="${2:?--base-delay needs a value}"; shift 2 ;;
    --max-delay)         MAX_DELAY_MS="${2:?--max-delay needs a value}"; shift 2 ;;
    --multiplier)        MULTIPLIER="${2:?--multiplier needs a value}"; shift 2 ;;
    --breaker-threshold) BREAKER_THRESHOLD="${2:?--breaker-threshold needs a value}"; shift 2 ;;
    --reset-timeout)     RESET_TIMEOUT_S="${2:?--reset-timeout needs a value}"; shift 2 ;;
    --state-dir)         STATE_DIR="${2:?--state-dir needs a value}"; shift 2 ;;
    --key)               BREAKER_KEY="${2:?--key needs a value}"; shift 2 ;;
    --log-file)          LOG_FILE="${2:?--log-file needs a value}"; shift 2 ;;
    -h|--help)           print_usage; exit 0 ;;
    --)                  shift; break ;;
    *)                   die detail="unknown_option" option="$1" ;;
  esac
done

[[ $# -gt 0 ]] || die detail="no_command" hint="pass a command after --"

for numeric in ATTEMPTS MULTIPLIER BREAKER_THRESHOLD; do
  value="${!numeric}"
  [[ "$value" =~ ^[0-9]+$ ]] || die detail="not_a_number" option="--${numeric,,}" value="$value"
  (( value > 0 )) || die detail="must_be_positive" option="--${numeric,,}" value="$value"
done
for numeric in BASE_DELAY_MS MAX_DELAY_MS RESET_TIMEOUT_S; do
  value="${!numeric}"
  [[ "$value" =~ ^[0-9]+$ ]] || die detail="not_a_number" option="--${numeric,,}" value="$value"
done
(( BASE_DELAY_MS <= MAX_DELAY_MS )) || die detail="base_delay_above_max" base="$BASE_DELAY_MS" max="$MAX_DELAY_MS"

CMD=( "$@" )
CMD_STR="${CMD[*]}"

command -v "${CMD[0]}" >/dev/null 2>&1 \
  || die detail="command_not_found" command="${CMD[0]}"

if [[ -n "$STATE_DIR" ]]; then
  mkdir -p "$STATE_DIR" || die detail="state_dir_unwritable" dir="$STATE_DIR"
  STATE_DIR="$(cd "$STATE_DIR" && pwd)"
fi
[[ -z "$LOG_FILE" ]] || touch "$LOG_FILE" || die detail="log_file_unwritable" file="$LOG_FILE"

# --- circuit breaker --------------------------------------------------------
#
# Three states, stored as files so a short-lived wrapper process can carry
# them between invocations:
#   closed    - failures file holds a count below the threshold; calls pass.
#   open      - opened file holds an epoch; calls are refused until the reset
#               timeout elapses.
#   half-open - after the timeout, exactly one caller wins the probe file and
#               is allowed through; everyone else is still refused.

state_path() {
  printf '%s/%s.%s' "$STATE_DIR" "$BREAKER_KEY" "$1"
}

now_epoch() {
  date -u +%s
}

# Run a mutation under an advisory lock when flock is available. The state
# files are small and rewritten whole, so a lost race loses one count, but
# serialising the read-modify-write keeps the threshold honest under a burst
# of concurrent wrappers.
with_state_lock() {
  if command -v flock >/dev/null 2>&1; then
    exec 9>"$(state_path lock)"
    flock 9
    "$@"
    flock -u 9
    exec 9>&-
  else
    log_event debug state_unlocked reason="flock_not_found"
    "$@"
  fi
}

breaker_opened_at() {
  local f
  f="$(state_path opened)"
  [[ -r "$f" ]] || return 1
  read -r t <"$f" || true
  [[ "$t" =~ ^[0-9]+$ ]] || return 1
  printf '%s' "$t"
}

# Decide whether this invocation may call the command. Prints "open",
# "half-open" or "closed". In half-open, ownership of the single probe has
# already been taken by this process. mkdir is the atomic primitive: exactly
# one caller can create the directory, so exactly one probe gets through.
breaker_admit() {
  if [[ -z "$STATE_DIR" ]]; then
    printf 'closed'
    return
  fi
  local opened_at now elapsed
  if opened_at="$(breaker_opened_at)"; then
    now="$(now_epoch)"
    elapsed=$(( now - opened_at ))
    if (( elapsed < RESET_TIMEOUT_S )); then
      printf 'open'
      return
    fi
    if mkdir "$(state_path probe)" 2>/dev/null; then
      rm -f "$(state_path opened)"
      log_event warn breaker_half_open key="$BREAKER_KEY" cooldown_s="$elapsed"
      printf 'half-open'
      return
    fi
    printf 'open'
    return
  fi
  printf 'closed'
}

# Increment the consecutive-failure count and open the breaker once the count
# reaches the threshold. Without a state dir there is nothing to count, so the
# retries still happen but the breaker stays closed for this invocation.
breaker_record_failure() {
  [[ -n "$STATE_DIR" ]] || return 0
  local new_count=0
  with_state_lock read_state_and_count
  if (( new_count >= BREAKER_THRESHOLD )); then
    with_state_lock open_circuit
    log_event error breaker_open key="$BREAKER_KEY" consecutive_failures="$new_count" \
      threshold="$BREAKER_THRESHOLD"
  else
    log_event warn breaker_failure key="$BREAKER_KEY" consecutive_failures="$new_count" \
      threshold="$BREAKER_THRESHOLD"
  fi
}

# Called by with_state_lock, so the read-modify-write is serialised.
read_state_and_count() {
  local n=0
  if [[ -r "$(state_path failures)" ]]; then
    read -r n <"$(state_path failures)" || true
  fi
  [[ "$n" =~ ^[0-9]+$ ]] || n=0
  n=$(( n + 1 ))
  printf '%s\n' "$n" >"$(state_path failures)"
  new_count="$n"
}

open_circuit() {
  printf '%s\n' "$(now_epoch)" >"$(state_path opened)"
}

breaker_record_success() {
  [[ -n "$STATE_DIR" ]] || return 0
  with_state_lock clear_circuit
}

clear_circuit() {
  rm -f "$(state_path failures)" "$(state_path opened)"
  rmdir "$(state_path probe)" 2>/dev/null || true
}

# --- backoff ----------------------------------------------------------------

# Jittered exponential backoff in milliseconds. The jitter window is the top
# half of the nominal delay, so a fleet of wrappers that all fail at the same
# instant does not resynchronise into the next instant.
backoff_ms() {
  local attempt="$1"
  local ms="$BASE_DELAY_MS"
  local i jitter floor
  for (( i = 1; i < attempt; i++ )); do
    ms=$(( ms * MULTIPLIER ))
    if (( ms >= MAX_DELAY_MS )); then
      ms="$MAX_DELAY_MS"
      break
    fi
  done
  floor=$(( ms / 2 ))
  jitter=$(( floor + (RANDOM * (ms - floor)) / 32767 ))
  printf '%s' "$jitter"
}

sleep_ms() {
  local ms="$1"
  sleep "$(printf '%d.%03d' "$(( ms / 1000 ))" "$(( ms % 1000 ))")"
}

# --- main loop --------------------------------------------------------------

STATE="$(breaker_admit)"
log_event info state key="$BREAKER_KEY" state="$STATE" attempts="$ATTEMPTS" \
  cmd="$(quote_value "$CMD_STR")"

if [[ "$STATE" == "open" ]]; then
  log_event error call_rejected key="$BREAKER_KEY" reason="breaker_open" \
    reset_timeout_s="$RESET_TIMEOUT_S"
  exit "$EXIT_CIRCUIT_OPEN"
fi

attempt=1
while :; do
  if "${CMD[@]}"; then
    rc=0
  else
    rc=$?
  fi

  if (( rc == 0 )); then
    breaker_record_success
    log_event info call_succeeded key="$BREAKER_KEY" attempt="$attempt" cmd="$(quote_value "$CMD_STR")"
    exit 0
  fi

breaker_record_failure >/dev/null

  if (( attempt >= ATTEMPTS )); then
    log_event error call_failed key="$BREAKER_KEY" attempts="$attempt" rc="$rc" \
      cmd="$(quote_value "$CMD_STR")"
    exit "$rc"
  fi

  delay="$(backoff_ms "$attempt")"
  log_event warn call_retry key="$BREAKER_KEY" attempt="$attempt" rc="$rc" \
    next_attempt="$(( attempt + 1 ))" delay_ms="$delay"
  sleep_ms "$delay"
  attempt=$(( attempt + 1 ))
done