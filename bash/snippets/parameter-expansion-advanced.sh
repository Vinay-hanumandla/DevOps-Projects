# last_verified: 2026-09-23 · Bash n/a
# parameter-expansion-advanced.sh — Advanced parameter expansion patterns.
#
# Purpose:
#   Demonstrate global substitution, prefix/suffix stripping, alternate
#   values, and nested expansions so scripts can reshape strings without
#   spawning subshells.
#
# When to use:
#   Use these expansions when normalizing paths, filenames, or
#   environment-derived values inline. Prefer them over sed/awk for
#   single-variable rewrites inside tight loops.
#
# Prerequisites:
#   bash only. No external commands.
#
# Steps:
#   Source the functions or run the script directly to print each
#   section. Each function is self-contained and prints its result.
#
# Verify:
#   Run: bash parameter-expansion-advanced.sh
#   Expect each section to print the expected rewritten value and exit 0.
#
# Common errors:
#   - Forgetting that unmatched patterns leave the value unchanged.
#   - Using ${var:+val} when ${var:-val} was meant (alternate vs default).
#   - Nesting too deep to read; split into named temporaries instead.

# Global substitution: replace every match.
# ${var//pat/rep} replaces all occurrences of glob pat with rep.
strip_global_replace() {
  local path="a:b:c:b"
  printf '%s\n' "${path//:/,}"      # a,b,c,b
  printf '%s\n' "${path//b/B}"      # a:B:c:B
}

# Longest/shortest affix removal.
# ${var%%pat} strips the longest trailing match; ${var##pat} strips
# the longest leading match. Single %/# strip the shortest match.
strip_affixes() {
  local file="archive.tar.gz"
  printf '%s\n' "${file%%.*}"       # archive (longest suffix from first dot)
  printf '%s\n' "${file%.*}"        # archive.tar (shortest suffix)
  printf '%s\n' "${file##*.}"       # gz (longest prefix up to last dot)
  printf '%s\n' "${file#*.}"        # tar.gz (shortest prefix)
}

# Alternate and default values.
# ${var:+val} expands to val only when var is set and non-empty.
# ${var:-val} expands to val only when var is unset or empty.
alternate_and_default() {
  local verbose="yes"
  local quiet=""
  printf '%s\n' "${verbose:+--verbose}"  # --verbose
  printf '%s\n' "${quiet:+--verbose}"    # (empty)
  printf '%s\n' "${quiet:-default-mode}" # default-mode
}

# Nested substitution: inner expansion feeds the outer one.
nested_substitution() {
  local env="  Staging  "
  local trimmed="${env// /}"            # Staging
  printf '%s\n' "${trimmed,,}"          # staging (lowercase)
  local image="registry/app:old"
  local repo="${image%%:*}"             # registry/app
  printf '%s\n' "${repo##*/}:current"   # app:current
}

strip_global_replace
strip_affixes
alternate_and_default
nested_substitution
