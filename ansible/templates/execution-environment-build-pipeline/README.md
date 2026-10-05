---
last_verified: 2026-10-05
tool_version: 2.21.4
sources:
  - https://api.github.com/repos/ansible/ansible/releases?per_page=8
  - https://raw.githubusercontent.com/ansible/ansible/v2.22.0b2/changelogs/CHANGELOG-v2.22.rst
---

# Execution Environment build pipeline scaffold

## Purpose

A build pipeline for an Ansible Execution Environment (EE): a multi-stage
`Containerfile` that resolves the Galaxy requirements in a build-only stage and
copies the result into the stage that ships, followed by a SBOM document, a
vulnerability scan that fails the run, and a verification step that asks the
built image what it actually contains. The pipeline runs four stages in a fixed
order — build, SBOM, scan, push — and pushes only after the scan gate passes.

## When to use

- The collection set of an automation has to be pinned per job instead of being
  inherited from whatever happens to be installed on the controller.
- The base image and the collection set are both reviewable inputs, so a change
  to either shows up as a diff rather than as drift on a shared runner.
- A released EE needs an SBOM attached to the artifact and a recorded decision
  about which severities block promotion.

It is not worth the machinery for a single-node run where installing
collections on the controller is cheaper than shipping an image.

## Prerequisites

- `ansible-builder` on `PATH`, a container engine on `PATH` (`podman` or
  `docker`), and `trivy` on `PATH`. `build-ee.sh` refuses to start when the
  build tool or the scanner is missing rather than degrading to a build without
  a gate.
- An execution-environment base image approved by the platform team, referenced
  by digest. `.env.example` ships a placeholder and the script rejects it, so an
  unpinned base cannot reach a released EE by accident.
- Ansible-core `2.21.4` is the current GA release, and the base image is
  expected to carry that cut. `verify-ee.sh` warns when the image reports
  another core version.

## Layout

| File | Role |
|---|---|
| `Containerfile` | Two stages: `galaxy` resolves requirements, `final` ships them |
| `requirements.yml` | Collections (and optionally roles) installed into the EE |
| `.env.example` | Every pin as an input: base image, image name, severities |
| `build-ee.sh` | build → SBOM → scan gate → optional push |
| `verify-ee.sh` | Runs the image and diffs it against `requirements.yml` |
| `.gitignore` | Keeps `.env` and `artifacts/` out of version control |

## Steps

1. Copy `.env.example` to `.env` and pin the inputs:

   ```bash
   cp .env.example .env
   $EDITOR .env          # EE_BASE_IMAGE by digest, EE_IMAGE, EE_TAG
   ```

2. Pin the collection set in `requirements.yml`. The shipped entries are
   deliberately unversioned: no collection version was verified when this
   scaffold was written, and an unchecked pin is worse than none.

3. Build, generate the SBOM, and pass the scan gate:

   ```bash
   ./build-ee.sh                      # uses .env
   ./build-ee.sh --image myorg/ee --tag ci-42 --push
   ```

   `--push` runs after the scan gate, so an unscanned image never reaches the
   registry. If `EE_IMAGE` already carries a tag, that tag wins over `EE_TAG`.

4. Verify the artifact:

   ```bash
   ./verify-ee.sh --image myorg/ee:ci-42
   ```

## Design decisions

- **The base image is a required build arg.** `EE_BASE_IMAGE` is declared in the
  `Containerfile` with no default, so an unset value fails the build instead of
  falling back to a base supplied implicitly by the build tool.
- **Resolution happens in its own stage.** Collections are installed into
  `/build/collections` in the `galaxy` stage and copied into the `final` stage.
  The dependency layer stays cacheable across unrelated `Containerfile` edits,
  and nothing that exists only to satisfy the build ships in the EE.
- **The role install is guarded.** `requirements.yml` carries a `roles:` key only
  when roles are actually needed, and the `galaxy` stage checks for that key
  before running the role install, so a collections-only file does not fail the
  build.
- **One tool does both jobs.** Trivy writes the CycloneDX SBOM and runs the scan
  gate, which keeps one tool to pin rather than two.
- **The gate is not negotiable in passing.** `--severities` and `--exit-code`
  exist, and narrowing them is a decision to record in review rather than a fix
  to make quietly.

## Version pinning

This scaffold cites no `ansible-builder`, Trivy, or base-image version, because
none was verified when it was written — an invented version in a scaffold is
copied verbatim into the first real pipeline. Pin those in the CI image, and
confirm the command surface against `ansible-builder build --help` for the
installed version. The Ansible-core claims are sourced: `2.21.4` is the current
GA release and `v2.22.0b2` is the newest pre-release.

### What changes when the EE moves to 2.22

- Task results handed to callback plugins are always masked with `$REDACTED$`,
  and the `ANSIBLE_SUPPORTS_MASKING` opt-in introduced in `2.22.0b1` has been
  removed and ignored. A custom callback written against b1 receives masked
  results and must be re-tested.
- At raised verbosity the `ssh`, `winrm`, and `psrp` connection plugins print
  only the return code, not raw stdout/stderr. `ANSIBLE_DEBUG=1` restores the raw
  output, but the same changelog lists that as a known issue: it can display
  target output before module secrets are registered for masking, so `no_log`
  values may appear in plaintext. Keep it off a shared runner.
- `ansible-config` actions now default to `-t all`, so plugin-owned config
  sections such as `[ssh_connection]` are validated. An EE that ships its own
  `ansible.cfg` can start reporting keys that were previously ignored.
- `ansible-connection` forces the persistent connection directory to private
  permissions. A runner that mounts a shared cache path can lose access to it.
- The galaxy stage of this `Containerfile` runs `ansible-galaxy` at build time.
  The 2.22 changelog security section names CVE-2026-11332 for
  `ansible-galaxy install` passing role requirements as positional arguments to
  `git clone`, where a malicious role author could inject git configuration.
  The changelog publishes no CVSS score and no affected/fixed range, so confirm
  both from an advisory before deciding which base image is acceptable.

## Verify

- `./verify-ee.sh` exits `0` and lists every required collection as `present`.
- A second `./build-ee.sh` reuses the cached dependency layer.
- Remove a collection from `requirements.yml` and re-run `verify-ee.sh`: it
  exits non-zero and names that collection as `MISSING`.
- Force a finding (`TRIVY_SEVERITIES=LOW ./build-ee.sh`): the gate fails with a
  non-zero exit and nothing is pushed.

## Common errors

| Symptom | Cause | Fix |
|---|---|---|
| `EE_BASE_IMAGE is still the placeholder` | `.env` copied but not edited | Pin the approved base image by digest |
| `WARN base image ... is not pinned by digest` | `EE_BASE_IMAGE` uses a tag | Reference the approved image by digest |
| `the Containerfile copies '<name>' from the build context` | `EE_REQUIREMENTS` points outside `EE_CONTEXT` | Keep the requirements file inside the context directory |
| `the built tag ... is not in the local <engine> store` | The installed `ansible-builder` does not leave the tag where the engine can see it | Check `ansible-builder build --help` for that version, then load the image or push and scan the pushed reference |
| No role install happens | `requirements.yml` has no `roles:` key | Expected — add the key when roles are needed |
| The gate fails on every build | The pinned base image carries a known finding | Bump the base image; do not narrow `--severities` to make the build green |
| `verify-ee.sh` reports every collection missing | The reference resolves to a different tag than the one built, or the image entrypoint was overridden | Re-check the resolved image reference before trusting the report |

## References

- Ansible releases API — the `2.21.4` GA and `v2.22.0b2` pre-release claims:
  <https://api.github.com/repos/ansible/ansible/releases?per_page=8>
- The `2.22` changelog — every 2.22 behaviour claim above, and the security
  entry naming CVE-2026-11332:
  <https://raw.githubusercontent.com/ansible/ansible/v2.22.0b2/changelogs/CHANGELOG-v2.22.rst>