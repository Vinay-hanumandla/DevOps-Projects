---
last_verified: 2026-10-20
tool_version: "ansible-core 2.21.5"
sources:
  - https://github.com/ansible/ansible/releases
---

# Ansible 2.20 to 2.21 migration guide

## Purpose

Plan and execute an upgrade of an Ansible control node and its collections from ansible-core 2.20 to ansible-core 2.21, covering breaking changes, collection compatibility, and validation.

## When to use

Use when pinning ansible-core to a new minor release across a team or CI pipeline. Apply to control nodes, execution environments, and collection requirements files together.

## Prerequisites

- A working ansible-core installation with a recorded version (`ansible --version`).
- Version-controlled playbooks, roles, and inventory.
- A staging environment that mirrors the target hosts.
- Collection requirements files (`requirements.yml`) pinned to versions.

## Steps

1. Inventory the current state. Record `ansible --version`, installed collections (`ansible-galaxy collection list`), and the Python version on the controller. Keep this as the rollback baseline.
2. Read the official porting guide for the target minor release before changing anything. Porting guides enumerate renamed/removed modules, changed default behaviors, and deprecated features with their removal version. Work through each item against your own codebase with `grep`.
3. Upgrade ansible-core in an isolated environment first (virtualenv or container). Do not upgrade the shared controller directly.
4. Reinstall collections against the new core version. Collections declare `requires_ansible` ranges; a collection that does not support 2.21 will fail to install or emit warnings. Pin collection versions that explicitly support 2.21.
5. Run `ansible-playbook --syntax-check` on every playbook. This catches removed module options and renamed FQCNs without connecting to hosts.
6. Run the test suite against staging with `serial: 1` first, then full batches. Watch for changed default behaviors (fact gathering, become, vault) that only surface at runtime.
7. Update Execution Environments / container images to the matching ansible-core version so CI and AWX use the same core as local development.
8. Update `requires_ansible` in any collections you publish so downstream users get a clear compatibility signal.

## Verify

- `ansible --version` reports 2.21.x on the upgraded controller.
- `ansible-galaxy collection list` shows collections compatible with 2.21.
- `ansible-playbook --syntax-check` passes for all playbooks.
- A full staging run completes with no deprecation warnings promoted to errors.

## Rollback

- Revert the controller to the 2.20 virtualenv/container image recorded in step 1.
- Reinstall the previous collection versions from `requirements.yml` pinned to the 2.20-compatible set.
- Revert Execution Environment images to the 2.20 tag.

## Common errors

- Collection install fails with a `requires_ansible` mismatch: pin a collection version that supports 2.21, or upgrade the collection first.
- Playbook syntax errors referencing removed module options: consult the porting guide and replace with the successor option.
- Runtime deprecation warnings that the new core promotes to errors: address the flagged call before it becomes a hard failure in the next minor release.

## References

- ansible-core releases: https://github.com/ansible/ansible/releases