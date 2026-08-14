#!/usr/bin/env bash
# last_verified: 2026-08-14 · git n/a
# Core release command: bump VERSION, commit it, tag v<version>, and push the
# tag plus the current branch when an origin remote exists. CWD-independent —
# it runs git against ROOT, so you can invoke it from anywhere.
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source-path=SCRIPT_DIR
# shellcheck source=../lib/common.sh
# shellcheck disable=SC1091
source "$ROOT/lib/common.sh"

main() {
    local step="${1:-patch}"
    local version_file new_version current branch

    require_git
    cd "$ROOT"
    assert_clean_tree

    version_file="$ROOT/VERSION"
    current="$(current_version "$version_file")"
    new_version="$(next_version "$current" "$step")"

    printf '%s\n' "$new_version" > "$version_file"
    git add VERSION
    git commit -m "chore(release): $new_version"
    git tag -a "v$new_version" -m "Release v$new_version"

    if git remote get-url origin >/dev/null 2>&1; then
        branch="$(git branch --show-current)"
        git push origin "HEAD:$branch"
        git push origin "v$new_version"
    else
        printf 'no origin remote; tag created locally only: v%s\n' "$new_version"
    fi
}

main "$@"