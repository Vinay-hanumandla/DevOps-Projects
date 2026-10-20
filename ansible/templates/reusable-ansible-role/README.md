---
last_verified: 2026-10-20
tool_version: n/a
sources:
  - https://docs.ansible.com/projects/ansible-core/2.20/tips_tricks/ansible_tips_tricks.html
---

# Reusable Ansible role template with Molecule, Galaxy, and CI

## Purpose

A starting layout for a reusable Ansible role that is unit-tested with Molecule,
packaged with Galaxy metadata (`galaxy.yml`), and gated by a CI workflow on every
push. Use it when a playbook has grown past inline tasks and needs its own
versioned, tested role rather than a one-off task list.

## When to use

- The role configures one service and needs `defaults`, `tasks`, `handlers`,
  `vars`, and `meta` separated the standard way.
- The team wants `molecule test` to run on push and pull request so a broken
  role never reaches a playbook.
- The role is published to Ansible Galaxy or an internal pull-through server,
  so `galaxy.yml` must declare namespace, name, version, and dependencies.
- CI should build the collection and lint it with galaxy-importer before a
  merge is allowed.

## Prerequisites

- Ansible and Molecule installed in the environment that runs the tests
  (deliberately unpinned here — pin versions in your own lockfile, not in a
  scaffold, so the template never cites a version it did not verify).
- Docker available if the Molecule driver creates containers.
- `ansible-galaxy collection build` and `galaxy-importer` for the CI lint job.

## Steps

1. Copy this directory as the root of the new role repo and rename
   `roles/app_role` and the namespace/name in `galaxy.yml` to the real ones.
2. Fill in `roles/app_role/defaults/main.yml` with the service settings that
   callers should be able to override.
3. Add tasks to `roles/app_role/tasks/main.yml`, using fully qualified
   collection names (`ansible.builtin.file`, `ansible.builtin.template`, …)
   and setting `state` explicitly on every resource task.
4. Add handlers to `roles/app_role/handlers/main.yml` and notify them on change
   so restarts only fire when something actually changed.
5. Declare role metadata and dependencies in `roles/app_role/meta/main.yml`.
6. Write the Molecule scenario in `molecule/default/molecule.yml` (driver,
   platforms, converge and verify playbooks) and the converge/verify playbooks
   underneath it.
7. Add the CI workflow in `.github/workflows/ci.yml` so Molecule and
   galaxy-importer run on every push and pull request.
8. Run `molecule test` locally before pushing; CI runs the same command.

## Verify

- `molecule test` passes: create, converge, verify, destroy.
- `ansible-playbook site.yml --check --diff` reports no unexpected changes on a
  second run (idempotence).
- `ansible-galaxy collection build` succeeds from the repo root.
- `galaxy-importer lint` reports no errors against the built tarball.
- The CI workflow passes on a push to a feature branch.

## Common errors

- `molecule test` fails at the create step when Docker is not running or the
  Molecule Docker plugin is not installed; start Docker and install
  `molecule-plugins[docker]` first.
- `galaxy-importer lint` complains about a missing `README.md` or an invalid
  `galaxy.yml`; add both and re-run the build before linting.
- A task that forgets `state: present` defaults to absent on some modules and
  removes the resource it was meant to create; set `state` explicitly.
- A handler that is never notified never runs; wire `notify` into every task
  that changes a service or config file.

## References

- [Ansible tips and tricks](https://docs.ansible.com/projects/ansible-core/2.20/tips_tricks/ansible_tips_tricks.html) — production patterns this scaffold follows: name every play and task, set `state` explicitly, use `serial` to batch updates, `group_by` for OS-specific work, fully qualified collection names, and version control for the audit trail.
