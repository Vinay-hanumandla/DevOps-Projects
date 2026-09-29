---
last_verified: 2026-09-29
tool_version: n/a
---

# Ansible collection scaffold with Molecule and galaxy-importer config

## Purpose

A starting layout for an Ansible collection that is tested with Molecule and
validated by galaxy-importer before publication. Use it when a set of roles has
outgrown a single playbook and needs collection namespacing, dependency
declaration, and a publication-quality metadata file. The scaffold also wires
a CI workflow that runs `molecule test` and `ansible-galaxy collection build`
plus a galaxy-importer lint pass on every push.

## When to use

- The collection ships one or more roles and needs `galaxy.yml` to declare the
  namespace, name, version, and dependencies.
- The team wants `molecule test` to gate merges via GitHub Actions.
- The collection is destined for Ansible Galaxy or an internal pull-through, so
  galaxy-importer runs as part of CI to catch metadata problems before publish.

## Prerequisites

- Ansible and Molecule installed in the environment that runs the tests
  (deliberately unpinned here — pin versions in your own lockfile, not in a
  scaffold, so the template never cites a version it did not verify).
- Docker available if the Molecule driver creates containers.
- `ansible-galaxy collection build` available with the same Ansible version that
  consumes the collection, so the version reported by `--version` matches the
  runtime.

## Steps

1. Copy this directory as the root of the new collection repo.
2. Rename the namespace and name in `galaxy.yml` to the real ones.
3. Add roles under `roles/` and playbooks under `playbooks/`; the collection
   auto-discovers both from `galaxy.yml` at build time.
4. Fill in `molecule/default/molecule.yml` with the driver and platforms you
   actually use.
5. Add the CI workflow:

   ```yaml
   name: ci
   on:
     push:
     pull_request:
   jobs:
     lint-and-test:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v4
         - uses: actions/setup-python@v5
           with:
             python-version: '3.x'
         - run: pip install molecule molecule-plugins[docker] ansible-lint
         - run: ansible-galaxy collection build
         - run: molecule test
   ```

6. Run galaxy-importer locally before publishing:

   ```bash
   ansible-galaxy collection build -o .
   galaxy-importer lint ./example_org-1.0.0.tar.gz
   ```

7. Publish with `ansible-galaxy collection publish`, then verify the import
   result in the Galaxy UI.

## Verify

- `ansible-galaxy collection build` succeeds from the repo root and produces a
  tarball that extracts to the expected directory layout.
- `molecule test` passes: create, converge, verify, destroy.
- `galaxy-importer lint` reports no errors against the built tarball.
- `ansible-galaxy collection install` from a fresh environment pulls and imports
  the collection without warnings.

## References

- Ansible collection metadata: the `galaxy.yml` schema documented in the
  Ansible collection authoring guide.
- galaxy-importer: the lint tool that validates a built collection tarball
  before it is published to Ansible Galaxy.
- Molecule: the testing framework for Ansible roles and collections, with the
  Docker driver used by this scaffold.