# last_verified: 2026-07-31 · bash 5.3.9
# Comparing [ ] vs [[ ]] and other Bash scripting gotchas
#
# Purpose:
#   Demonstrate the practical differences between POSIX [ ] and bash [[ ]]
#   test constructs, along with common pitfalls that trip up scripters
#   at L3. Each example is runnable and includes inline commentary on
#   why a particular pattern matters.
#
# Steps:
#   Run the script and compare output sections. Each function illustrates
#   one gotcha or comparison point.
#
# Verify:
#   Execute the script with bash and confirm the exit code matches the
#   comments on each function.

set -euo pipefail

# ---------------------------------------------------------------------------
# 1. [ ] vs [[ ]] — string equality
# ---------------------------------------------------------------------------
# With [ ], unquoted variables undergo word-splitting and glob expansion,
# which causes errors or false matches when values contain spaces or
# wildcard characters. [[ ]] does not split or glob.

compare_string_unquoted() {
  local val="hello world"
  if [ "$val" = "hello world" ]; then
    echo "[ ] with quotes: match"
  else
    echo "[ ] with quotes: no match"
  fi
}

compare_string_unquoted_fail() {
  # This is what happens when you forget quotes with [ ] — the script
  # will fail or behave unexpectedly when the value contains spaces.
  # With [[ ]], quoting is optional because [[ ]] does not word-split.
  local val="hello world"
  # The following line would fail if unquoted:
  #   if [ $val = "hello world" ]; then
  # It works with [[ ]] because [[ ]] does not perform word-splitting.
  if [[ $val == "hello world" ]]; then
    echo "[ ] with [[ ]] (quoted): match"
  fi
}

# ---------------------------------------------------------------------------
# 2. [ ] vs [[ ]] — pattern matching
# ---------------------------------------------------------------------------
# [[ ]] supports glob patterns and regex with == and =~.

pattern_match() {
  local filename="archive.tar.gz"
  if [[ $filename == *.tar.gz ]]; then
    echo "glob match: .tar.gz extension detected"
  fi
  if [[ $filename =~ \.tar\.gz$ ]]; then
    echo "regex match: .tar.gz extension detected"
  fi
}

# ---------------------------------------------------------------------------
# 3. set -euo pipefail edge cases
# ---------------------------------------------------------------------------
# Under set -e, arithmetic expressions that evaluate to zero exit with
# code 1, killing the script. Use count=$((count + 1)) instead of
# (( count++ )) when -e is active.

counter_example() {
  local count=0
  # (( count++ )) returns exit code 1 when count is 0 (post-increment
  # evaluates to the old value, which is 0). Under set -e this kills the
  # script. Instead, use arithmetic expansion which always returns 0.
  count=$((count + 1))
  echo "counter after increment: $count"
}

# ---------------------------------------------------------------------------
# 4. Unquoted variables and word-splitting
# ---------------------------------------------------------------------------
# rm $file breaks when $file contains spaces. Always quote variables.

safe_rm() {
  local file="my file.txt"
  # This is safe:
  # rm -- "$file"
  # The -- prevents filenames starting with - from being interpreted as
  # options, and quoting prevents word-splitting on spaces.
  echo "would run: rm -- $file (UNSAFE)"
  echo "would run: rm -- \"$file\" (safe)"
}

# ---------------------------------------------------------------------------
# 5. getopts only handles short flags
# ---------------------------------------------------------------------------
# Long options like --verbose require a while/case loop or a parsing library.
# Beginners who only learn getopts cannot build modern CLIs.

parse_long_flags() {
  # getopts handles -v and -h but not --verbose or --help.
  # A while/case loop is needed for long options.
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --verbose)
        verbose=true
        shift
        ;;
      --help)
        echo "Usage: script [--verbose] [--help]"
        return 0
        ;;
      *)
        echo "Unknown option: $1" >&2
        return 1
        ;;
    esac
  done
  echo "long-flag parsing complete"
}

# ---------------------------------------------------------------------------
# Run examples
# ---------------------------------------------------------------------------
echo "=== 1. [ ] vs [[ ]] — string equality ==="
compare_string_unquoted
compare_string_unquoted_fail

echo ""
echo "=== 2. [ ] vs [[ ]] — pattern matching ==="
pattern_match

echo ""
echo "=== 3. set -euo pipefail edge cases ==="
counter_example

echo ""
echo "=== 4. Unquoted variables ==="
safe_rm

echo ""
echo "=== 5. Long flag parsing ==="
parse_long_flags --verbose --help

echo ""
echo "=== All examples completed ==="