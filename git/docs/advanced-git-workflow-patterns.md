---
last_verified: 2026-10-15
tool_version: n/a
---

# Advanced Git workflow patterns: monorepo strategies, commit signing, and bisect automation

## Purpose

This reference describes three workflow patterns used on larger Git repositories: organizing a monorepo so teams can work in one history without stepping on each other, requiring commit signing so history is attributable, and automating `git bisect` so regressions are located mechanically rather than by guesswork.

## When to use

| Pattern | Use when... | Avoid when... |
|---|---|---|
| Monorepo with path-scoped ownership | Several services or packages share release cadence and you want atomic cross-cutting changes. | Teams need fully independent histories and access boundaries; separate repos are simpler. |
| Required commit signing | You need every commit attributable to a key holder, e.g. for audit trails on protected branches. | The team has no key distribution story yet; unsigned history with branch protection is the interim step. |
| Bisect automation | A regression has a reproducible pass/fail test and a known-good boundary commit. | The failure is flaky or environment-dependent; bisect will point at noise instead of the cause. |

## Prerequisites

- A clone with full history (bisect and log-following need the commits locally).
- Write access to the branch protection settings if you plan to enforce signing.
- A one-command check script that exits zero on good and non-zero on bad, for the bisect run.

## Steps

### 1. Monorepo strategies

Keep one root with a directory per deployable unit and a short top-level map so newcomers can orient:

```text
repo/
  services/api/
  services/worker/
  libs/shared/
  docs/
```

Three scoping habits keep this workable:

1. **Path-scoped reviews.** Assign reviewers by directory (e.g. changes under `services/api/` go to the API owners). Most hosting platforms support path-based ownership files; check in one and keep it current.
2. **Narrow clones and partial checkouts for daily work.** Use a sparse checkout limited to the directories you touch so status and checkout stay fast, while the full history remains available for cross-cutting changes.
3. **Scoped log queries.** When tracing a regression in one service, restrict history to its path (`git log -- <path>`) instead of reading the whole-repo log.

### 2. Commit signing

Signing attaches a verifiable identity to each commit. The practical rollout order is:

1. Each author configures a signing key locally and signs with `git commit -S`.
2. The team publishes the public halves of the keys where reviewers can find them.
3. Branch protection is switched to reject unsigned commits on the integration branches only — leave feature branches permissive until everyone can sign reliably.
4. CI verifies signatures on merge (show signature status in the merge check) rather than each author re-verifying by hand.

### 3. Bisect automation

Manual bisect works but is slow; script it:

```bash
git bisect start
git bisect bad HEAD
git bisect good <known-good-commit>
git bisect run ./check-regression.sh
```

`check-regression.sh` is the one-command test from Prerequisites. `git bisect run` checks out each candidate, runs the script, and narrows to the first bad commit automatically. When it reports the culprit, inspect that commit's diff, then end the session:

```bash
git bisect reset
```

Keep the check script hermetic: seed any randomness, point it at a disposable data directory, and make it print the assertion that failed so the bisect log is readable afterward.

## Verify

- `git log --show-signature -3` shows a valid signature on recent integration-branch commits.
- `git bisect log` (before `reset`) shows a clean good/bad sequence ending at a single culprit commit.
- A fresh clone with the sparse-checkout paths set contains only the expected directories but `git log` still shows full history.

## Common errors

| Symptom | Cause | Fix |
|---|---|---|
| Bisect keeps landing on unrelated commits | The check script is flaky or depends on leftover state. | Make the script clean its work directory on each run and re-run the suspect range twice. |
| Signed commits verify locally but CI flags them | CI cannot see the public key. | Publish the key where the CI check looks it up; re-run the merge check. |
| Sparse checkout hides files a script needs | The checkout scope is narrower than the build inputs. | Add the missing path to the sparse scope and re-apply. |

## References

- `signed-commits-and-ci-provenance.md` — signing setup and CI provenance checks in this folder.
- `comparing-merge-rebase-squash-strategies.md` — how merge vs rebase vs squash history styles interact with monorepo review.
