#!/usr/bin/env bash
# last_verified: 2026-08-14 · git n/a
# changelog.sh: print a convention-driven changelog section for the release on
# stdout. Gracefully handles the "no tags yet" case by scanning all commits.
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source-path=SCRIPT_DIR
# shellcheck source=../lib/common.sh
# shellcheck disable=SC1091
source "$ROOT/lib/common.sh"

main() {
    local since_range last_tag
    require_git

    # shellcheck disable=SC2155
    last_tag="$(git describe --tags --abbrev=0 2>/dev/null || true)"
    if [ -n "$last_tag" ]; then
        since_range="${last_tag}..HEAD"
    else
        since_range="HEAD"
    fi

    printf '# Changelog\n\n'
    git log --no-merges --pretty=format:'- %s' "$since_range" \
        | grep -E '^- (feat|fix|docs|chore|refactor|perf):' || true
    printf '\n'
}

main "$@"