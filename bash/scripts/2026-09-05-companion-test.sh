#!/usr/bin/env bash
# last_verified: 2026-09-05 · Bash 5.3.0
# Companion test.sh for the install-and-first-script note
# (2026-07-18-install-bash-and-first-script.md).

echo "hello from bash $BASH_VERSION"

tmp="/tmp/bash_first_test_$$"
printf '#!/usr/bin/env bash\necho "Script ran OK"\n' > "$tmp"
chmod +x "$tmp"

if "$tmp" | grep -q "Script ran OK"; then
  echo "Test passed: first-script example works."
else
  echo "Test FAILED: expected output not found." >&2
  exit 1
fi
rm -f "$tmp"
