#!/usr/bin/env bash
# last_verified: 2026-09-30 · git n/a
# update-changelog.sh — rewrite the `## [Unreleased]` block of a changelog
# from the conventional commits that landed since the last release tag.
#
# Contract:
#   * The Unreleased block is REPLACED, never appended to. Running the script
#     twice over the same commit range leaves the file byte-identical, so the
#     workflow that calls it can commit whatever comes out without a guard.
#   * Commits whose type appears in SKIP_TYPES are dropped, so chore/ci/build
#     noise never reaches a changelog.
#   * An empty range is not an error: the script reports it and exits 0 with
#     the changelog untouched.
#   * A missing `## [Unreleased]` heading IS an error — silently appending a
#     second one is how changelogs grow duplicate sections.
#
# Environment:
#   CHANGELOG_FILE  changelog to rewrite          (default CHANGELOG.md)
#   TAG_PREFIX      release-tag prefix            (default v)
#   SKIP_TYPES      space-separated types to drop (default "chore ci build")
#
# The GitHub Actions workflow calls this as `bash scripts/update-changelog.sh`.
# It is plain bash + git + awk so it runs the same way in a runner and in a
# terminal, and it can be pointed at a scratch copy of the changelog to check
# that the generator still works before the change reaches the default branch.
set -Eeuo pipefail

CHANGELOG_FILE="${CHANGELOG_FILE:-CHANGELOG.md}"
TAG_PREFIX="${TAG_PREFIX:-v}"
SKIP_TYPES="${SKIP_TYPES:-chore ci build}"
UNRELEASED_HEADING='## [Unreleased]'

# Diagnostics go to stderr: the range computed in commit_range is captured
# with command substitution, and a log line on stdout would be captured with
# it.
log() { printf '[changelog] %s\n' "$*" >&2; }

on_error() {
    local code=$?
    log "line=$1 cmd='$2' exit=$code"
}
trap 'on_error "${LINENO}" "${BASH_COMMAND}"' ERR

cleanup() { rm -f "${BODY_FILE:-}" "${BLOCK_FILE:-}" "${OUT_FILE:-}"; }
trap cleanup EXIT

# Conventional-commit type of a subject line, lowercased. Prints nothing when
# the subject does not start with `type:`, `type(scope):` or `type!:`, which
# is the signal that the commit does not follow the convention the scaffold's
# commit-msg hook enforces.
commit_type() {
    printf '%s' "$1" |
        sed -n 's/^\([A-Za-z][A-Za-z0-9]*\)\(([^)]*)\)\{0,1\}\(!\)\{0,1\}:.*/\1/p' |
        tr '[:upper:]' '[:lower:]'
}

# Changelog heading a commit type is filed under.
heading_for_type() {
    case "$1" in
        feat) printf 'Added' ;;
        fix) printf 'Fixed' ;;
        *) printf 'Changed' ;;
    esac
}

skipped_type() {
    local candidate="$1" skip
    for skip in $SKIP_TYPES; do
        if [ "$candidate" = "$skip" ]; then
            return 0
        fi
    done
    return 1
}

# The revision range the Unreleased block is generated from: everything after
# the most recent release tag, or the whole history when no tag exists yet.
commit_range() {
    local last_tag
    if last_tag="$(git describe --tags --abbrev=0 --match "${TAG_PREFIX}*" 2>/dev/null)"; then
        printf '%s..HEAD\n' "$last_tag"
        return 0
    fi
    log "no ${TAG_PREFIX}* tag found; generating from the whole history"
    printf 'HEAD\n'
}

# Collect one `heading<TAB>subject` line per releasable commit, newest first.
collect_commits() {
    local range="$1" subject type
    # `git log --pretty=format:` emits no trailing newline, so the last
    # subject arrives as a partial line: the `|| [ -n "$subject" ]` guard is
    # what keeps it from being dropped.
    while IFS= read -r subject || [ -n "$subject" ]; do
        type="$(commit_type "$subject")"
        if [ -n "$type" ] && skipped_type "$type"; then
            continue
        fi
        printf '%s\t%s\n' "$(heading_for_type "${type:-other}")" "$subject"
    done < <(git log --no-merges --pretty=format:'%s' "$range")
}

# Render the collected lines into grouped markdown bullet lists. Groups are
# emitted in a fixed Added / Changed / Fixed order rather than in the order
# the commits happen to appear in, so the changelog reads the same way twice.
render_block() {
    awk -F'\t' '
        function rank(heading) {
            if (heading == "Added") return 1
            if (heading == "Changed") return 2
            if (heading == "Fixed") return 3
            return 4
        }
        {
            if (!($1 in seen)) {
                order[++count] = $1
                seen[$1] = 1
            }
            bullets[$1] = bullets[$1] "- " $2 "\n"
        }
        END {
            for (i = 2; i <= count; i++) {
                candidate = order[i]
                j = i - 1
                while (j > 0 && (rank(order[j]) > rank(candidate) ||
                                 (rank(order[j]) == rank(candidate) && order[j] > candidate))) {
                    order[j + 1] = order[j]
                    j--
                }
                order[j + 1] = candidate
            }
            for (i = 1; i <= count; i++) {
                if (i > 1) printf "\n"
                printf "### %s\n\n%s", order[i], bullets[order[i]]
            }
        }
    ' "$1" >"$2"
}

# Replace the Unreleased heading and its body with the freshly rendered block,
# leaving the rest of the file (front matter, released version blocks, link
# definitions at the bottom) exactly where it was.
splice_block() {
    awk -v heading="$UNRELEASED_HEADING" -v block="$BLOCK_FILE" '
        BEGIN {
            while ((getline rendered < block) > 0) {
                body = body rendered ORS
            }
            close(block)
        }
        !replaced && $0 == heading {
            print heading
            print ""
            printf "%s", body
            print ""
            replaced = 1
            skipping = 1
            next
        }
        skipping && /^## / { skipping = 0 }
        skipping { next }
        { print }
    ' "$CHANGELOG_FILE" >"$OUT_FILE"
}

main() {
    local range

    if [ ! -f "$CHANGELOG_FILE" ]; then
        log "ERROR: changelog '$CHANGELOG_FILE' not found"
        exit 1
    fi
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        log "ERROR: not inside a git repository; cannot read the commit range"
        exit 1
    fi
    if ! grep -Fxq "$UNRELEASED_HEADING" "$CHANGELOG_FILE"; then
        log "ERROR: '$UNRELEASED_HEADING' heading missing from '$CHANGELOG_FILE'"
        exit 1
    fi

    BODY_FILE="$(mktemp)"
    BLOCK_FILE="$(mktemp)"
    OUT_FILE="$(mktemp)"

    range="$(commit_range)"
    collect_commits "$range" >"$BODY_FILE"
    log "range=$range releasable_commits=$(wc -l <"$BODY_FILE" | tr -d ' ')"

    if [ ! -s "$BODY_FILE" ]; then
        log "nothing to record; '$CHANGELOG_FILE' left unchanged"
        return 0
    fi

    render_block "$BODY_FILE" "$BLOCK_FILE"
    splice_block
    # Write through the existing file rather than renaming the temp file over
    # it: mktemp creates 0600, and a renamed file would silently tighten the
    # mode on a file the repository already tracks.
    cat "$OUT_FILE" >"$CHANGELOG_FILE"
    log "rewrote the Unreleased block of '$CHANGELOG_FILE'"
}

main "$@"
