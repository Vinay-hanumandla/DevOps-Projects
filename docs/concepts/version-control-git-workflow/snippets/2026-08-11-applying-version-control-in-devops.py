# last_verified: 2026-08-11 · version-control-git-workflow n/a
# I wrote this to practice applying version control in DevOps: turning a
# branch's commit history into a release changelog. The habit I'm building
# is treating commit messages as structured data (conventional commits)
# instead of free text, so release notes come from git itself rather than
# someone's memory of what changed.

SAMPLE_COMMITS = [
    "a1b2c3d feat: add health endpoint for the load balancer",
    "e4f5a6b fix(cache): expire stale entries after 60s",
    "c7d8e9f docs: update the deploy runbook",
    "0a1b2c3 feat!: switch config format to YAML",
    "d4e5f6a chore: bump a dependency patch",
]

SECTIONS = {
    "feat": "New features",
    "fix": "Bug fixes",
    "docs": "Docs",
    "chore": "Chores",
    "refactor": "Refactors",
}


def classify(subject):
    """Conventional commits look like 'feat: add health check'."""
    for prefix in SECTIONS:
        if subject.startswith(f"{prefix}:"):
            return prefix
    return None


def build_changelog(commits):
    """Group recognized commits by type, oldest to newest."""
    entries = {key: [] for key in SECTIONS}
    for line in commits:
        short_hash, _, subject = line.partition(" ")
        kind = classify(subject)
        if kind:
            entries[kind].append(f"- {subject} ({short_hash})")
    return {k: v for k, v in entries.items() if v}


changelog = build_changelog(SAMPLE_COMMITS)
if not changelog:
    print("No recognized commits.")
else:
    for kind, heading in SECTIONS.items():
        if changelog.get(kind):
            print(f"## {heading}")
            for entry in changelog[kind]:
                print(entry)
