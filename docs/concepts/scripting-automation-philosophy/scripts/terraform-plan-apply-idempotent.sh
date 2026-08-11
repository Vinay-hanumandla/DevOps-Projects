#!/usr/bin/env bash
# last_verified: 2026-08-11 · scripting-automation-philosophy n/a
# terraform-plan-apply-idempotent.sh — validate, plan, then apply for one environment.
#
# This script combines the Scripting & Automation Philosophy with IaC: the plan
# is the trust anchor (validate -> plan -> apply), the saved plan file is the
# artifact that apply consumes, and idempotency is a contract — re-running the
# same plan produces the same result, never a fresh surprise.
#
# Usage: ./terraform-plan-apply-idempotent.sh <env> <validate|plan|apply>

set -euo pipefail

ENV="${1:-}"
ACTION="${2:-}"
PLAN_FILE="plan-${ENV}.tfplan"
ENV_DIR="terraform/${ENV}"

# Scripts take flags, never prompts — fail fast on a bad invocation.
if [ -z "$ENV" ] || [ -z "$ACTION" ]; then
    echo "usage: $0 <env> <validate|plan|apply>" >&2
    exit 2
fi

# Whitelist the environment so we can't accidentally target the wrong one.
case "$ENV" in
    staging | production) ;;
    *)
        echo "unknown env: $ENV (allowed: staging, production)" >&2
        exit 2
        ;;
esac

if [ ! -d "$ENV_DIR" ]; then
    echo "no directory found for env: $ENV_DIR" >&2
    exit 1
fi

cd "$ENV_DIR"

case "$ACTION" in
    validate)
        # Fast gate, no state contact: catches formatting and syntax drift.
        terraform fmt -check
        terraform validate
        ;;
    plan)
        # Save the exact plan as a binary artifact; apply must use this file.
        terraform init -input=false
        terraform plan -out="$PLAN_FILE"
        echo "plan saved to $ENV_DIR/$PLAN_FILE — review it before applying"
        ;;
    apply)
        # Never apply without a reviewed plan artifact.
        if [ ! -f "$PLAN_FILE" ]; then
            echo "no saved plan at $ENV_DIR/$PLAN_FILE — run 'plan' first" >&2
            exit 1
        fi
        # Consume the exact saved plan so re-runs stay deterministic.
        terraform apply "$PLAN_FILE"
        ;;
    *)
        echo "unknown action: $ACTION (allowed: validate, plan, apply)" >&2
        exit 2
        ;;
esac
