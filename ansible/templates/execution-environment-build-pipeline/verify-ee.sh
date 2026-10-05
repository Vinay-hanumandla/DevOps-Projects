#!/usr/bin/env bash
# last_verified: 2026-10-05 · ansible 2.21.4
# ansible-023 — Post-build verification for the execution-environment scaffold.
# Level: L5 | Output: template
#
# Purpose: prove the built image is runnable and carries the collection set the
#   requirements file asked for, by asking the image itself rather than trusting
#   the build log.
# When to use: after build-ee.sh, before the image is promoted or referenced by
#   a job template; and in CI as the last step of the EE pipeline.
# Prerequisites: a container engine on PATH, and an image reference the engine
#   can resolve — the tag build-ee.sh printed, or the pushed registry reference.
# Steps: resolve engine -> ask the image for `ansible --version` -> ask it for
#   `ansible-galaxy collection list` -> diff both against requirements.yml and
#   the expected core version.
# Verify: delete a collection name from requirements.yml and confirm this script
#   exits non-zero naming that collection as missing.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

die() {
    printf 'verify-ee: %s\n' "$*" >&2
    exit 1
}

log() {
    printf '==> %s\n' "$*"
}

usage() {
    cat <<'EOF'
Usage: verify-ee.sh --image NAME[:TAG] [options]

Options:
  --image NAME[:TAG]     Image reference to verify (default: $EE_IMAGE:$EE_TAG)
  --requirements PATH    Galaxy requirements file (default: $EE_REQUIREMENTS)
  --expect-core VERSION  Warn if the image reports another ansible-core
                         (default: $EXPECTED_CORE_VERSION)
  --engine NAME          Container engine (default: $CONTAINER_ENGINE, auto-detected)
  -h, --help             Show this help
EOF
}

resolve_path() {
    local path
    case "$1" in
        /*) path="$1" ;;
        *)  path="$SCRIPT_DIR/${1#./}" ;;
    esac
    printf '%s' "${path%/.}"
}

detect_engine() {
    local candidate
    for candidate in podman docker; do
        if command -v "$candidate" >/dev/null 2>&1; then
            printf '%s' "$candidate"
            return 0
        fi
    done
    return 1
}

required_collections() {
    awk '
        /^collections:/ { in_collections = 1; next }
        /^roles:/      { in_collections = 0 }
        in_collections && /^[[:space:]]*-[[:space:]]*name:/ { print $NF }
    ' "$1"
}

ENV_FILE="$SCRIPT_DIR/.env"
if [[ -f "$ENV_FILE" ]]; then
    set -a
    # shellcheck source=/dev/null
    source "$ENV_FILE"
    set +a
fi

IMAGE="${EE_IMAGE:-}"
TAG="${EE_TAG:-dev}"
ENGINE="${CONTAINER_ENGINE:-}"
EXPECT_CORE="${EXPECTED_CORE_VERSION:-}"
REQUIREMENTS="$(resolve_path "${EE_REQUIREMENTS:-requirements.yml}")"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --image)        IMAGE="${2:?--image needs a value}"; shift 2 ;;
        --requirements) REQUIREMENTS="$(resolve_path "${2:?--requirements needs a value}")"; shift 2 ;;
        --expect-core)  EXPECT_CORE="${2:?--expect-core needs a value}"; shift 2 ;;
        --engine)       ENGINE="${2:?--engine needs a value}"; shift 2 ;;
        -h|--help)      usage; exit 0 ;;
        *)              usage >&2; die "unknown argument: $1" ;;
    esac
done

[[ -n "$IMAGE" ]] || die "no image reference: set EE_IMAGE in .env or pass --image"
[[ -f "$REQUIREMENTS" ]] || die "requirements file not found: $REQUIREMENTS"

if [[ "$IMAGE" == *:* && "${IMAGE##*/}" == *:* ]]; then
    REF="$IMAGE"
else
    REF="${IMAGE}:${TAG}"
fi

if [[ -z "$ENGINE" ]]; then
    ENGINE="$(detect_engine)" \
        || die "no container engine on PATH (looked for podman, then docker)"
fi
command -v "$ENGINE" >/dev/null 2>&1 || die "container engine '$ENGINE' is not on PATH"

# ── The image has to be runnable ────────────────────────────────────────────
log "Asking $REF for its ansible-core version"
if ! version_output="$("$ENGINE" run --rm --entrypoint ansible "$REF" --version 2>&1)"; then
    printf '%s\n' "$version_output" >&2
    die "could not run 'ansible --version' inside $REF — the image is not usable as an EE"
fi
printf '%s\n' "$version_output"

reported_core="$(printf '%s\n' "$version_output" \
    | grep -oE 'core [0-9]+\.[0-9]+\.[0-9]+' | head -n 1 | awk '{print $2}' || true)"
if [[ -z "$reported_core" ]]; then
    printf 'verify-ee: WARN could not parse an ansible-core version out of the image output\n' >&2
elif [[ -n "$EXPECT_CORE" && "$reported_core" != "$EXPECT_CORE" ]]; then
    printf 'verify-ee: WARN image reports ansible-core %s, expected %s — an EE that drifted from the pinned core behaves differently from the controller you tested on\n' \
        "$reported_core" "$EXPECT_CORE" >&2
fi

# ── The collection set must match the requirements ──────────────────────────
log "Asking $REF for its installed collection list"
if ! list_output="$("$ENGINE" run --rm --entrypoint ansible-galaxy "$REF" collection list 2>&1)"; then
    printf '%s\n' "$list_output" >&2
    die "could not run 'ansible-galaxy collection list' inside $REF"
fi

missing=0
checked=0
while IFS= read -r collection; do
    [[ -n "$collection" ]] || continue
    checked=$((checked + 1))
    if printf '%s\n' "$list_output" | grep -qwF -- "$collection"; then
        printf '  %-40s present\n' "$collection"
    else
        printf '  %-40s MISSING\n' "$collection"
        missing=$((missing + 1))
    fi
done < <(required_collections "$REQUIREMENTS")

if (( checked == 0 )); then
    die "no collection names parsed from $REQUIREMENTS — nothing was verified"
fi

if (( missing > 0 )); then
    die "$missing of $checked required collections are missing from $REF"
fi

log "All $checked required collections are present in $REF"