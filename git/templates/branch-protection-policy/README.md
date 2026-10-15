---
last_verified: 2026-10-15
tool_version: n/a
---

# Branch protection policy workflow

## Purpose

Keep branch protection under version control. The policy that guards the
default branch — required reviews, required status checks, linear history —
lives in `policy/branch-protection.json`, is reviewed like any other change,
and is applied to the repository by `scripts/apply-protection.sh` or by the
`Branch protection` workflow. `scripts/verify-protection.sh` detects drift
between the file and the live settings, and `scripts/remove-protection.sh`
rolls the policy back.

## When to use

Use this template when a repository has outgrown click-through protection
settings: several maintainers, a CI suite whose check names must be
enforced rather than remembered, or a compliance need to show exactly which
rules were in force at a given commit. It fits repositories with a single
long-lived branch as well as ones with additional release branches — each
protected branch is one key in the policy file. It does not replace
`CODEOWNERS` or per-team review assignment; it enforces that the review
happened, not who performed it.

## Prerequisites

- `git`, `gh`, and `jq` on the machine that runs the scripts.
- A credential with admin on the target repository. The default workflow
  token is not sufficient for changing protection, so application uses an
  admin-scoped credential (`GH_TOKEN` locally, the `ADMIN_TOKEN` secret in
  the workflow).
- The branch names listed in the policy file already exist on the remote.
  Branches that do not exist yet are skipped with a warning, not created.
- The status check names listed under `contexts` match the check names CI
  actually reports. The template ships with an empty list, which applies
  the review, history, and deletion rules but enforces no checks until real
  names are filled in.

## Layout

```
branch-protection-policy/
├── README.md
├── policy/
│   └── branch-protection.json
├── scripts/
│   ├── apply-protection.sh
│   ├── verify-protection.sh
│   └── remove-protection.sh
└── .github/
    └── workflows/
        └── branch-protection.yml
```

`policy/branch-protection.json` maps each exact branch name to the full
protection payload for that branch. The payload is sent as-is in a single
call, because the protection endpoint replaces the entire policy: sending
reviews and checks in separate calls would wipe whichever half was applied
first. `required_approving_review_count` is 1 with stale approvals
dismissed on push, history must be linear, force pushes and deletions are
off, and signed commits are off until deliberately enabled.

## Steps

1. Copy the template into the repository and edit
   `policy/branch-protection.json`: set `contexts` to the CI check names to
   require, raise `required_approving_review_count` if one review is not
   enough, and add further exact branch names as new keys for release
   branches. Flip `required_signatures.enabled` to `true` only when every
   committer already signs.
2. Open a pull request with the change. The `validate` job checks the file
   shape — at least one branch, a `contexts` array on each — and syntax
   checks the three scripts. Merging never changes protection by itself.
3. Run the `Branch protection` workflow with `workflow_dispatch`, optionally
   passing a subset of branches, or run the script from a terminal:
   `scripts/apply-protection.sh --repo OWNER/REPO`. The script validates the
   file, skips branches missing on the remote, applies each payload, and
   reads the policy back.
4. Run `scripts/verify-protection.sh --repo OWNER/REPO` to confirm the live
   settings match the file field by field.

## Verify

The verify script exits 0 only when every branch in the policy file carries
exactly the stored settings. A representative passing run ends with:

```
OK: main required_linear_history.enabled = true
OK: main allow_force_pushes.enabled = false
OK: main allow_deletions.enabled = false
PASS: all policy branches match policy/branch-protection.json
```

Schedule the workflow's verify path after any bulk repository change, and
re-run it before audits: a green run is the evidence that the file and the
repository agree.

## Rollback

Protection is removed per branch, never implicitly. To roll back, run
`scripts/remove-protection.sh --repo OWNER/REPO main` (branch names are
always explicit arguments, so deleting a branch from the policy file cannot
silently unprotect it) and confirm with the repository name when prompted,
or pass `--yes` for automation. Removing protection does not delete
branches, commits, or history; it only lifts the merge rules. Re-apply with
`apply-protection.sh` to restore the policy from the file.

## Common errors

| Symptom | Likely cause | Fix |
|---|---|---|
| Apply fails with the repository not found | `--repo` slug misspelled, or the credential has no access | Correct the slug; check the credential can view the repository |
| Branch skipped with a does-not-exist warning | Policy lists a branch never pushed to the remote | Push the branch first, or drop the key from the policy file |
| Verify reports drift on `contexts` right after apply | CI renamed a check, or the file lists a check that never reported | Update `contexts` to the names CI actually reports, then re-apply |
| Merges blocked with no failing check visible | `strict` requires branches to be up to date, or `contexts` is still empty while reviewers expect enforcement | Update the branch and re-run CI; fill in real check names if the list is empty |
| Workflow apply fails on permissions | `ADMIN_TOKEN` missing, or the credential lacks admin | Store an admin-scoped credential as `ADMIN_TOKEN`; the default token cannot change protection |

## References

- The single-branch variant of this policy inside the repository scaffold:
  [repo-scaffold README](../repo-scaffold/README.md).
- Commit signing, for the day `required_signatures` gets enabled:
  [signed commits and CI provenance](../../docs/signed-commits-and-ci-provenance.md).
