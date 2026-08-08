#!/usr/bin/env bash
# last_verified: 2026-08-08 · terraform n/a

# Runs the three terraform steps in order: init, plan, apply
# I use this instead of typing each command manually

TF_DIR="${1:-.}"
cd "$TF_DIR" || exit 1

echo "=== terraform init ==="
terraform init

echo "=== terraform plan ==="
terraform plan

echo "=== terraform apply (auto-approve) ==="
terraform apply -auto-approve
