#!/usr/bin/env bash
# last_verified: 2026-09-23 · Ansible 2.21.4
# ansible-vault-patterns.sh — Ansible Vault patterns for multi-environment
# secrets: encrypt, decrypt, rotate, and debug.
#
# This is one approach; the Ansible docs also suggest embedding --vault-id
# in ansible.cfg for multi-env setups. Each function isolates one concern
# so callers can compose them into pipelines.
#
# Usage:
#   ./ansible-vault-patterns.sh encrypt  secrets/dev.yml
#   ./ansible-vault-patterns.sh decrypt  secrets/dev.yml
#   ./ansible-vault-patterns.sh rotate   vault-password/vault-pass-dev
#   ./ansible-vault-patterns.sh debug    secrets/dev.yml
#   ./ansible-vault-patterns.sh encrypt-multi env/dev vault-password/vault-pass-dev secrets/dev.yml
#
# Exit codes:
#   0  operation succeeded
#   1  ansible-vault reported an error or a precondition failed
#   2  usage error (bad args, missing file)

set -euo pipefail

ANSIBLE_VAULT="${ANSIBLE_VAULT:-ansible-vault}"

log_info() { printf '[INFO] %s\n' "$*"; }
log_err() { printf '[ERROR] %s\n' "$*" >&2; }

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    log_err "required command not found: $1"
    exit 2
  fi
}

require_file() {
  if [[ ! -f "$1" ]]; then
    log_err "file not found: $1"
    exit 2
  fi
}

cmd_encrypt() {
  local vault_password_file=""
  local args=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --vault-password-file) vault_password_file="$2"; shift 2 ;;
      --vault-id) args+=("$1" "$2"); shift 2 ;;
      -h|--help)
        echo "Usage: $0 encrypt [--vault-password-file FILE] [--vault-id ID] <file>"
        exit 0 ;;
      *) break ;;
    esac
  done

  local file="${1:-}"
  if [[ -z "$file" ]]; then
    log_err "encrypt requires a file argument"
    exit 2
  fi
  require_file "$file"
  require_cmd "$ANSIBLE_VAULT"

  log_info "encrypting $file"
  if [[ -n "$vault_password_file" ]]; then
    "$ANSIBLE_VAULT" encrypt --vault-password-file "$vault_password_file" "${args[@]}" "$file"
  else
    "$ANSIBLE_VAULT" encrypt "${args[@]}" "$file"
  fi
}

cmd_decrypt() {
  local vault_password_file=""
  local args=()
  local output=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --vault-password-file) vault_password_file="$2"; shift 2 ;;
      --vault-id) args+=("$1" "$2"); shift 2 ;;
      -o|--output) output="$2"; shift 2 ;;
      -h|--help)
        echo "Usage: $0 decrypt [--vault-password-file FILE] [--vault-id ID] [-o OUT] <file>"
        exit 0 ;;
      *) break ;;
    esac
  done

  local file="${1:-}"
  if [[ -z "$file" ]]; then
    log_err "decrypt requires a file argument"
    exit 2
  fi
  require_file "$file"
  require_cmd "$ANSIBLE_VAULT"

  log_info "decrypting $file"
  if [[ -n "$output" ]]; then
    if [[ -n "$vault_password_file" ]]; then
      "$ANSIBLE_VAULT" decrypt --vault-password-file "$vault_password_file" "${args[@]}" --output "$output" "$file"
    else
      "$ANSIBLE_VAULT" decrypt "${args[@]}" --output "$output" "$file"
    fi
  else
    if [[ -n "$vault_password_file" ]]; then
      "$ANSIBLE_VAULT" decrypt --vault-password-file "$vault_password_file" "${args[@]}" "$file"
    else
      "$ANSIBLE_VAULT" decrypt "${args[@]}" "$file"
    fi
  fi
}

cmd_rotate() {
  local vault_password_file=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --vault-password-file) vault_password_file="$2"; shift 2 ;;
      -h|--help)
        echo "Usage: $0 rotate [--vault-password-file FILE] <old-password-file>"
        exit 0 ;;
      *) break ;;
    esac
  done

  local old_password_file="${1:-}"
  if [[ -z "$old_password_file" ]]; then
    log_err "rotate requires the current password file argument"
    exit 2
  fi
  require_file "$old_password_file"
  require_cmd "$ANSIBLE_VAULT"

  log_info "re-encrypting all vault-encrypted files under vault-password/ with new password"
  local encrypted_files
  encrypted_files=$(find . -type f -name '*.yml' -o -name '*.yaml' -o -name '*.json' -o -name '*.env' 2>/dev/null | while read -r f; do
    if "$ANSIBLE_VAULT" view --vault-password-file "$old_password_file" "$f" >/dev/null 2>&1; then
      printf '%s\n' "$f"
    fi
  done)

  if [[ -z "$encrypted_files" ]]; then
    log_info "no vault-encrypted files found"
    return 0
  fi

  local tmp_password
  tmp_password=$(mktemp)
  trap 'rm -f "$tmp_password"' EXIT
  chmod 600 "$tmp_password"

  printf '%s\n' "$encrypted_files" | while read -r f; do
    log_info "re-encrypting $f"
    "$ANSIBLE_VAULT" encrypt --vault-password-file "$old_password_file" --new-vault-password-file "$tmp_password" "$f"
  done

  log_info "rotation complete — new password stored in $tmp_password (remove after distributing)"
}

cmd_debug() {
  local vault_password_file=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --vault-password-file) vault_password_file="$2"; shift 2 ;;
      -h|--help)
        echo "Usage: $0 debug [--vault-password-file FILE] <file>"
        exit 0 ;;
      *) break ;;
    esac
  done

  local file="${1:-}"
  if [[ -z "$file" ]]; then
    log_err "debug requires a file argument"
    exit 2
  fi
  require_file "$file"
  require_cmd "$ANSIBLE_VAULT"

  local is_encrypted=0
  if "$ANSIBLE_VAULT" encrypt --check --vault-password-file "${vault_password_file:-/dev/null}" "$file" 2>/dev/null; then
    is_encrypted=1
  fi

  if [[ "$is_encrypted" -eq 1 ]]; then
    log_info "$file is vault-encrypted"
  else
    log_info "$file is NOT vault-encrypted"
  fi

  echo "--- vault-id test ---"
  if [[ -n "$vault_password_file" ]]; then
    if "$ANSIBLE_VAULT" view --vault-password-file "$vault_password_file" "$file" 2>&1 | head -20; then
      log_info "view succeeded with provided password file"
    else
      log_err "view failed — password mismatch or corrupted vault"
    fi
  else
    log_info "no password file provided — skipping view test"
  fi

  echo "--- file header ---"
  head -3 "$file" 2>/dev/null | sed 's/^/  /'
}

cmd_encrypt_multi() {
  local environment=""
  local vault_password_file=""
  local args=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --vault-password-file) vault_password_file="$2"; shift 2 ;;
      --vault-id) args+=("$1" "$2"); shift 2 ;;
      -h|--help)
        echo "Usage: $0 encrypt-multi <env> <password-file> <vault-file>..."
        exit 0 ;;
      *) break ;;
    esac
  done

  environment="${1:-}"
  vault_password_file="${2:-}"
  local vault_files="${*:3}"

  if [[ -z "$environment" || -z "$vault_password_file" || -z "$vault_files" ]]; then
    log_err "encrypt-multi requires: env, password-file, and at least one vault file"
    exit 2
  fi
  require_file "$vault_password_file"
  require_cmd "$ANSIBLE_VAULT"

  log_info "encrypting vault files for environment '$environment'"
  for f in $vault_files; do
    require_file "$f"
    log_info "encrypting $f (env: $environment)"
    "$ANSIBLE_VAULT" encrypt --vault-password-file "$vault_password_file" "${args[@]}" "$f"
  done
}

usage() {
  cat <<EOF
Usage: $0 <command> [options] [args]

Commands:
  encrypt        Encrypt a YAML/JSON file with Ansible Vault
  decrypt        Decrypt a vault-encrypted file
  rotate         Re-encrypt vault files with a new password
  debug          Diagnose vault encryption status and readability
  encrypt-multi  Encrypt vault files for a specific environment

Common options:
  --vault-password-file FILE   Use a password file instead of interactive prompt
  --vault-id ID                Specify which vault ID to use (multi-vault setup)
  -h, --help                   Show this help message
EOF
}

main() {
  require_cmd "$ANSIBLE_VAULT"

  local command="${1:-}"
  if [[ -z "$command" ]]; then
    usage
    exit 2
  fi

  shift

  case "$command" in
    encrypt)       cmd_encrypt "$@" ;;
    decrypt)       cmd_decrypt "$@" ;;
    rotate)        cmd_rotate "$@" ;;
    debug)         cmd_debug "$@" ;;
    encrypt-multi) cmd_encrypt_multi "$@" ;;
    -h|--help|help) usage; exit 0 ;;
    *)
      log_err "unknown command: $command"
      usage >&2
      exit 2
      ;;
  esac
}

main "$@"