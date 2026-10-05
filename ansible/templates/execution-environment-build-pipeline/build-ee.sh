#!/usr/bin/env bash
# last_verified: 2026-10-05 · ansible 2.21.4
# ansible-023 — Execution Environment build pipeline: build, SBOM, scan, push.
# Level: L5 | Output: template
#
# Purpose: one entry point that turns ../Containerfile into a scanned execution
#   environment image — build, attach an SBOM document, fail on a Trivy finding,
#   and only then optionally push.
# When to use: in CI on every change to requirements.yml or the Containerfile,
#   and locally whenever the collection set of an EE is being changed.
# Prerequisites: ansible-builder on PATH; a container engine on PATH (podman or
#   docker); trivy on PATH; EE_BASE_IMAGE pinned by digest in .env.
# Steps: read .env -> validate inputs -> build -> SBOM -> scan gate -> push.
# Verify: ./verify-ee.sh --image <the tag printed below> resolves the collection
#   set from inside the image; a second build reuses the cached dependency layer.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

die() {
    printf 'build-ee: %s\n' "$*" >&2
    exit 1
}

log() {
    printf '==> %s\n' "$*"
}

usage() {
    cat <<'EOF'
Usage: build-ee.sh [options]

Options:
  --image NAME[:TAG]     Image name for the built EE (default: $EE_IMAGE)
  --tag TAG              Tag to apply when --image carries none (default: $EE_TAG, dev)
  --base-image REF       Base image for both Containerfile stages
                         (default: $EE_BASE_IMAGE)
  --context DIR          Build context (default: $EE_CONTEXT, this directory)
  --containerfile PATH   Containerfile (default: $EE_CONTAINERFILE, ./Containerfile)
  --requirements PATH    Galaxy requirements file (default: $EE_REQUIREMENTS)
  --severities LIST      Comma-separated scan severities (default: $TRIVY_SEVERITIES)
  --exit-code N          Exit code the scan gate uses on a finding (default: $TRIVY_EXIT_CODE)
  --artifact-dir DIR     Where the SBOM is written (default: $ARTIFACT_DIR)
  --engine NAME          Container engine (default: $CONTAINER_ENGINE, auto-detected)
  --push                 Push after the scan gate passes (default: $PUSH)
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

# docker has no `image exists`; podman does. Everything else falls back to
# `image inspect`, which both engines implement.
engine_image_exists() {
    case "$ENGINE" in
        podman) "$ENGINE" image exists "$1" >/dev/null 2>&1 ;;
        *)      "$ENGINE" image inspect "$1" >/dev/null 2>&1 ;;
    esac
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
BASE_IMAGE="${EE_BASE_IMAGE:-}"
ENGINE="${CONTAINER_ENGINE:-}"
SEVERITIES="${TRIVY_SEVERITIES:-HIGH,CRITICAL}"
EXIT_CODE="${TRIVY_EXIT_CODE:-1}"
PUSH="${PUSH:-false}"
CONTEXT="$(resolve_path "${EE_CONTEXT:-.}")"
CONTAINERFILE="$(resolve_path "${EE_CONTAINERFILE:-Containerfile}")"
REQUIREMENTS="$(resolve_path "${EE_REQUIREMENTS:-requirements.yml}")"
ARTIFACT_DIR="$(resolve_path "${ARTIFACT_DIR:-./artifacts}")"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --image)         IMAGE="${2:?--image needs a value}"; shift 2 ;;
        --tag)           TAG="${2:?--tag needs a value}"; shift 2 ;;
        --base-image)    BASE_IMAGE="${2:?--base-image needs a value}"; shift 2 ;;
        --context)       CONTEXT="$(resolve_path "${2:?--context needs a value}")"; shift 2 ;;
        --containerfile) CONTAINERFILE="$(resolve_path "${2:?--containerfile needs a value}")"; shift 2 ;;
        --requirements)  REQUIREMENTS="$(resolve_path "${2:?--requirements needs a value}")"; shift 2 ;;
        --severities)    SEVERITIES="${2:?--severities needs a value}"; shift 2 ;;
        --exit-code)     EXIT_CODE="${2:?--exit-code needs a value}"; shift 2 ;;
        --artifact-dir)  ARTIFACT_DIR="$(resolve_path "${2:?--artifact-dir needs a value}")"; shift 2 ;;
        --engine)        ENGINE="${2:?--engine needs a value}"; shift 2 ;;
        --push)          PUSH=true; shift ;;
        -h|--help)       usage; exit 0 ;;
        *)               usage >&2; die "unknown argument: $1" ;;
    esac
done

# ── Input validation ────────────────────────────────────────────────────────
[[ -n "$IMAGE" ]] || die "no image name: set EE_IMAGE in .env or pass --image"
[[ -n "$TAG" ]] || die "no tag: set EE_TAG in .env or pass --tag"
[[ -n "$BASE_IMAGE" ]] || die "no base image: set EE_BASE_IMAGE in .env or pass --base-image"
[[ "$BASE_IMAGE" != REPLACE_WITH_PINNED_BASE_IMAGE_BY_DIGEST ]] \
    || die "EE_BASE_IMAGE is still the placeholder from .env.example — pin the approved base image"
if [[ "$BASE_IMAGE" != *@sha256:* ]]; then
    printf 'build-ee: WARN base image %s is not pinned by digest\n' "$BASE_IMAGE" >&2
fi

command -v ansible-builder >/dev/null 2>&1 \
    || die "ansible-builder is not on PATH; the build stage has no fallback"
command -v trivy >/dev/null 2>&1 \
    || die "trivy is not on PATH; the SBOM and scan stages are part of this pipeline"

if [[ -z "$ENGINE" ]]; then
    ENGINE="$(detect_engine)" \
        || die "no container engine on PATH (looked for podman, then docker)"
fi
command -v "$ENGINE" >/dev/null 2>&1 || die "container engine '$ENGINE' is not on PATH"

[[ -f "$CONTAINERFILE" ]] || die "Containerfile not found: $CONTAINERFILE"
[[ -f "$REQUIREMENTS" ]] || die "requirements file not found: $REQUIREMENTS"
[[ -f "$CONTEXT/$(basename "$REQUIREMENTS")" ]] \
    || die "the Containerfile copies '$(basename "$REQUIREMENTS")' from the build context, but $CONTEXT does not contain it"

if [[ "$IMAGE" == *:* && "${IMAGE##*/}" == *:* ]]; then
    REF="$IMAGE"
else
    REF="${IMAGE}:${TAG}"
fi

mkdir -p "$ARTIFACT_DIR"

# ── Build ───────────────────────────────────────────────────────────────────
log "Building $REF from $CONTAINERFILE (context: $CONTEXT)"
ansible-builder build \
    --file "$CONTAINERFILE" \
    --context "$CONTEXT" \
    --tag "$REF" \
    --build-arg "EE_BASE_IMAGE=$BASE_IMAGE"

if ! engine_image_exists "$REF"; then
    die "the built tag $REF is not in the local $ENGINE store, so it cannot be scanned.
       Check how the installed ansible-builder hands its output to the engine
       ('ansible-builder build --help'), then either load the image into $ENGINE
       or build with --push and re-run the scan against the pushed reference."
fi

# ── SBOM ────────────────────────────────────────────────────────────────────
SBOM_PATH="${ARTIFACT_DIR}/${REF//[:\/]/_}.sbom.cdx.json"
log "Writing SBOM to $SBOM_PATH"
trivy image --format cyclonedx --output "$SBOM_PATH" "$REF"
[[ -s "$SBOM_PATH" ]] || die "trivy exited 0 but wrote an empty SBOM document"

# ── Scan gate ───────────────────────────────────────────────────────────────
log "Scanning $REF (fails the build on: $SEVERITIES)"
scan_status=0
trivy image --severity "$SEVERITIES" --exit-code "$EXIT_CODE" "$REF" || scan_status=$?
if (( scan_status != 0 )); then
    printf 'build-ee: scan gate failed for %s at severities %s\n' "$REF" "$SEVERITIES" >&2
    printf 'build-ee: inspect the table above, fix the finding, or record a decision to narrow --severities\n' >&2
    exit "$scan_status"
fi

# ── Push ────────────────────────────────────────────────────────────────────
if [[ "$PUSH" == true ]]; then
    log "Pushing $REF"
    "$ENGINE" push "$REF"
else
    log "Skipping push (set PUSH=true in .env or pass --push)"
fi

log "Build pipeline complete for $REF"
printf 'Next: %s/verify-ee.sh --image %s\n' "$SCRIPT_DIR" "$REF"
printf 'SBOM:  %s\n' "$SBOM_PATH"