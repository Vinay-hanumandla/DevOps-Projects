---
last_verified: 2026-10-03
tool_version: ansible-core 2.21
sources:
  - https://docs.ansible.com/ansible/latest/reference_appendices/release_and_maintenance.html
---

# Ansible Automation Platform 2.7 Migration Guide

## Purpose

Reference guide for migrating to Ansible Automation Platform (AAP) 2.7, which ships on ansible-core 2.21. Covers the gateway-only architecture, containerized installer, execution environment changes, and the ansible-core 2.21 support lifecycle that underpins the platform release.

## When to Use

- Planning an upgrade from AAP 2.x (ansible-core 2.19 or earlier) to AAP 2.7
- Evaluating the gateway-only deployment model for disconnected or air-gapped environments
- Building or rebuilding execution environments for the new ansible-builder workflow
- Aligning internal automation standards with the 2.21 interpreter and deprecation boundaries

## Prerequisites

- Existing AAP 2.x deployment or ansible-core 2.19/2.20 control nodes
- Access to Red Hat registry for container images (gateway, installer, execution environment base images)
- Container runtime (Podman or Docker) for the containerized installer and EE builds
- Python 3.12–3.14 on control nodes; Python 3.9–3.14 on target nodes (per ansible-core 2.21 support matrix)

## Support Lifecycle Context

ansible-core 2.21 (GA May 2026) is the only line still receiving general bug fixes past November 2026. ansible-core 2.19 has been security-only since 18 May 2026 and reaches EOL November 2026. ansible-core 2.20 moves to security-only on 02 November 2026. Pin ansible-core 2.21 for any automation that must remain supported past November 2026.

The three-tier maintenance model applies: newest release (2.21) receives security and general bug fixes; next release (2.20) receives security and critical fixes; third release (2.19) receives only security fixes. New features are never backported.

## Gateway-Only Architecture

AAP 2.7 introduces a gateway-only deployment option. The platform gateway replaces the traditional multi-service control plane with a single containerized entry point that handles API traffic, authentication, and job dispatch. Key implications:

- Reduced infrastructure footprint — fewer services to operate and monitor
- Simplified disconnected/air-gapped installations — only the gateway image and its dependencies must be mirrored
- Execution environments run on separate execution nodes; the gateway does not execute playbooks directly
- Existing hybrid deployments (control plane + execution nodes) remain supported; migration is not forced

## Containerized Installer

The AAP 2.7 installer is distributed as a container image rather than an RPM or bundle. The installer container runs the setup playbooks internally and manages the gateway deployment.

Typical workflow:
1. Pull the installer image from registry.redhat.io
2. Prepare an inventory file describing the target hosts and gateway configuration
3. Run the installer container with the inventory and credentials mounted
4. The container executes the setup playbooks and reports status

This model aligns with the execution environment philosophy — the installer itself runs in a controlled, reproducible container.

## Execution Environment Changes

AAP 2.7 standardizes on execution environments (EEs) built with ansible-builder. The platform gateway does not include Ansible content; all automation runs in EEs on execution nodes.

Changes from prior versions:
- ansible-builder is the required build tool; legacy `ansible-playbook` execution on the control plane is deprecated for platform-managed jobs
- EE base images are provided by Red Hat (Universal Base Image derivatives) and include ansible-core 2.21
- SBOM generation and Trivy scanning can be integrated into the EE build pipeline (see ansible-023 template)
- Execution environments are versioned and promoted through the platform gateway API

Collection and role dependencies are declared in `execution-environment.yml` and resolved at build time, not at runtime.

## Interpreter and Compatibility Boundaries

ansible-core 2.21 requires:
- Control node: Python 3.12–3.14 (3.11 is no longer supported)
- Target node: Python 3.9–3.14
- Windows: PowerShell 7.x LTS (7.6 LTS, Mar 2026–Nov 2028) — Windows PowerShell 5.1 is no longer supported on 2.21

A control node on Python 3.11 can run ansible-core 2.19 but not 2.21. Plan control-node Python upgrades before migrating.

## Deprecation Window

ansible-core deprecations span 4 feature releases — something deprecated in 2.10 is removed in 2.13. The clock counts releases, not version numbers. Community-package deprecations are recommended to last at least one year.

Review the 2.21 changelog for deprecations that affect your playbooks and roles. Common areas: module parameter changes, plugin loader paths, and inventory parser behavior.

## Upgrade Procedure

1. **Inventory current ansible-core version** — `ansible --version` on all control nodes
2. **Verify Python compatibility** — ensure control nodes can run Python 3.12+ and target nodes Python 3.9+
3. **Build new execution environments** — update `execution-environment.yml` for ansible-core 2.21 base image; run ansible-builder; scan with Trivy
4. **Test in staging** — run representative playbooks against the new EEs; validate module behavior, collection compatibility, and credential handling
5. **Deploy gateway** — use the containerized installer to deploy the AAP 2.7 gateway; configure authentication (OIDC, LDAP) and execution node registration
6. **Migrate projects and templates** — import existing job templates; verify they reference the new EE images
7. **Cut over** — redirect CI/CD pipelines and scheduled jobs to the new gateway; monitor for deprecation warnings
8. **Decommission old control plane** — once all workloads are validated, retire the legacy control plane services

## Common Errors

| Symptom | Cause | Resolution |
|---------|-------|------------|
| `ModuleNotFoundError` for collections in EE | Collection not declared in `execution-environment.yml` | Add collection to `dependencies` section and rebuild EE |
| Control node fails to start | Python version < 3.12 | Upgrade control node Python to 3.12–3.14 |
| `ansible-playbook` works locally but fails on execution node | EE missing system dependencies (e.g., krb5, openldap) | Extend EE base image with required system packages in `Containerfile` |
| Gateway installer times out pulling images | Air-gapped environment without mirrored images | Mirror all required images (gateway, EE base, installer) to internal registry before install |

## References

- Ansible Release and Maintenance Policy: https://docs.ansible.com/ansible/latest/reference_appendices/release_and_maintenance.html