# last_verified: 2026-08-20 · version-control-git-workflow n/a
# Applying version control in DevOps — release-readiness commit inventory.
# Every release cycle I've watched, someone asked "is that fix on the branch?"
# and nobody could answer from memory. Git can: the symmetric diff form
# `git log <release>..main` lists commits reachable from main but not from the
# release branch — exactly the "not shipped yet" set. Practice habit: ask git,
# don't ask a person.

import subprocess

RELEASE = "origin/release"


def unreleased_commits(release=RELEASE):
    cmd = ["git", "log", "--oneline", "--no-merges", f"{release}..main"]
    try:
        out = subprocess.run(cmd, capture_output=True, text=True, check=True).stdout
    except subprocess.CalledProcessError:
        return None
    return [line for line in out.splitlines() if line.strip()]


commits = unreleased_commits()
if commits is None:
    print(f"could not compare against {RELEASE}; is the ref fetched?")
elif not commits:
    print(f"nothing on main is missing from {RELEASE} — branch is in sync")
else:
    print(f"commits on main not yet on {RELEASE}:")
    for c in commits:
        print(" ", c)