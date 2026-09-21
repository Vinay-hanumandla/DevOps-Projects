---
last_verified: 2026-09-21
tool_version: n/a
---

# Integrating Git with signed commits and CI provenance

## Purpose

This document covers how to make Git commits verifiable and how to connect that verifiability to CI/CD pipelines. It covers three related concerns: signing commits with GPG or SSH keys, protecting pushes with branch rules and push protection, and producing build attestation that links a published artifact back to the exact source commit, the build environment, and the CI run that produced it.

## When to use

| Concern | Use when... | Avoid when... |
|---|---|---|
| GPG commit signing | You want a widely supported signature that verifies author identity against a published key. | You do not want to manage a private key on every machine that writes commits. |
| SSH commit signing | You already ship SSH keys to machines and want signatures verified by the same key material. | Your CI system cannot fetch the public half of the signing key. |
| Push protection | You want secrets or unsigned commits blocked before they reach the remote. | You push only to a self-hosted runner with no secret-scanning capability. |
| Build attestation | You need a machine-readable link from a container image or release artifact to the source commit and build provenance. | You publish artifacts only to internal registries that already enforce provenance. |

## Prerequisites

- Git 2.34+ for `git commit -S` with SSH keys and `gpg.format = ssh`.
- A signing key (GPG or SSH) whose public half is published to the account that will verify it.
- A CI system that can access the signing key or verification material in a secret store.
- A container registry that supports attestation uploads (or an attestation store alongside it).

## Signing commits

### GPG signing

GPG is the longest-supported option. Generate a key, publish the public key to your Git host and to keyservers, and configure Git to use it:

```bash
git config --global user.signingkey <key-id>
git config --global gpg.program gpg
git commit -S -m "feat: signed commit"
```

The signature is stored in the commit object. Verification is done with `git verify-commit`.

### SSH signing

SSH keys are already present on most machines, so signing with them reduces key-management overhead. Configure Git to treat SSH keys as signing material:

```bash
git config --global user.signingkey <ssh-key-path>
git config --global gpg.format ssh
git commit -S -m "feat: ssh-signed commit"
```

Verification requires the corresponding public key in `~/.ssh/authorized_keys` (or the equivalent on the host) and `gpg.ssh.allowedSignersFile` configured.

## Push protection and branch rules

Signed commits are only useful if the remote enforces them. Branch protection rules on the Git host require signed commits, require status checks, and prevent force-pushes to protected branches. Push protection adds a pre-receive check that scans the pushed content for secrets and rejects unsigned commits before they are written to the repository.

## Build attestation

Attestation ties a published artifact to the inputs that produced it. A typical attestation record includes:

- The source commit SHA and the repository ref.
- The CI run identifier and the workflow name.
- The build environment (runner image, tool versions).
- A digest of the artifact (for example, a container image manifest digest).

The CI pipeline generates the attestation at the end of the build and attaches it to the artifact in the registry. Consumers can then verify that the artifact was built from the expected commit, in the expected environment, by the expected workflow.

## Verify

- `git verify-commit <ref>` — confirms the commit is signed and the signature is valid.
- `git log --show-signature -1` — shows the signature status for the most recent commit.
- Check the branch protection rules on the host: confirm "Require signed commits" is enabled.
- Pull an attestation from the registry and confirm the commit SHA matches the source ref.

## Common errors

| Symptom | Cause | Fix |
|---|---|---|
| `git commit -S` fails with "No secret key" | The signing key is not installed or not the one configured. | Confirm `user.signingkey` matches an available key. |
| Signature is present but verification fails | The verifier does not have the public key. | Publish the public key to the allowed signers file or the host account. |
| Push is rejected for an unsigned commit | Push protection or branch rules require signatures. | Sign the commit before pushing, or disable the rule if it is not appropriate. |
| Attestation is missing from the registry | The CI workflow did not generate or upload it. | Add the attestation step to the build job and confirm the registry supports it. |