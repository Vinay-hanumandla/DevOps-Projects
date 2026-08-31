#!/usr/bin/env bash
# last_verified: 2026-08-31 · Ansible 2.21.3
# Ansible ad-hoc workflow toolkit: ping, gather facts, syntax-check, dry-run.
# Usage: ./ansible-adhoc-toolkit.sh <inventory> <playbook>

INVENTORY="${1:?Usage: $0 <inventory> <playbook>}"
PLAYBOOK="${2:?Usage: $0 <inventory> <playbook>}"

echo "=== Ping all hosts ==="
ansible all -i "$INVENTORY" -m ansible.builtin.ping

echo ""
echo "=== Gather facts from all hosts ==="
ansible all -i "$INVENTORY" -m ansible.builtin.setup --tree /tmp/facts/

echo ""
echo "=== Syntax-check playbook ==="
ansible-playbook -i "$INVENTORY" "$PLAYBOOK" --syntax-check

echo ""
echo "=== Dry-run (check mode) ==="
ansible-playbook -i "$INVENTORY" "$PLAYBOOK" --check --diff

echo ""
echo "=== Summary ==="
echo "Inventory: $INVENTORY"
echo "Playbook:  $PLAYBOOK"
echo "Review the dry-run output above, then run without --check to apply."
