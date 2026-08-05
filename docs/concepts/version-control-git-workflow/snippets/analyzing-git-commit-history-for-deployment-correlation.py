# last_verified: 2026-08-05 · python n/a
"""Analyze git commit history and correlate commits with deployment events."""

import subprocess
import re
from datetime import datetime


def run_git_log(since=None, until=None):
    """Run git log and return parsed commit entries."""
    cmd = [
        "git", "log",
        "--pretty=format:%H|%ai|%s|%an",
        "--date-order",
    ]
    if since:
        cmd.append(f"--since={since}")
    if until:
        cmd.append(f"--until={until}")

    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
    except subprocess.CalledProcessError as exc:
        print(f"git log failed: {exc.stderr.strip()}")
        return []

    if not result.stdout.strip():
        return []

    commits = []
    for line in result.stdout.strip().split("\n"):
        parts = line.split("|", 3)
        if len(parts) == 4:
            commits.append({
                "hash": parts[0],
                "date": parts[1],
                "message": parts[2],
                "author": parts[3],
            })
    return commits


def is_deployment_commit(message):
    """Check whether a commit message indicates a deployment event."""
    patterns = [
        r"\bdeploy\b",
        r"\brelease\b",
        r"\bproduction\b",
        r"\brelease\s*:\s*",
    ]
    return any(re.search(p, message, re.IGNORECASE) for p in patterns)


def correlate(commits):
    """Return commits that look like deployment events."""
    return [c for c in commits if is_deployment_commit(c["message"])]


def main():
    commits = run_git_log()
    if not commits:
        print("No commits found or git log failed.")
        return

    deployments = correlate(commits)
    print(f"Total commits analyzed: {len(commits)}")
    print(f"Deployment-related commits: {len(deployments)}")
    print("-" * 60)
    for d in deployments:
        print(f"{d['date']}  {d['hash'][:7]}  {d['message']}  ({d['author']})")


if __name__ == "__main__":
    main()