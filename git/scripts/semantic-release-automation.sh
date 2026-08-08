#!/usr/bin/env bash
# last_verified: 2026-08-08 · git n/a

# semantic-release-automation.sh
# Purpose: demonstrate a minimal semantic-release-like flow using only
# standard Git commands. This is one way to wire version bumps, tag
# creation, and push into a single script. The docs also suggest that
# real-world setups may parse conventional commits and integrate with
# CI, but this example keeps the surface small enough to run locally.

set -euo pipefail

LAB="/tmp/git-semantic-lab-$(date +%s)"
mkdir -p "$LAB"
cd "$LAB"

git init
git config user.email "learner@example.com"
git config user.name "Git Learner"

echo "0.1.0" > VERSION
git add VERSION
git commit -m "chore: initial version 0.1.0"

echo "alpha" > app.txt
git add app.txt
git commit -m "feat: add application placeholder"

echo "beta" > app.txt
git add app.txt
git commit -m "fix: update placeholder text"

CURRENT_VERSION="$(cat VERSION)"
echo "Current version before release: $CURRENT_VERSION"

MAJOR="$(echo "$CURRENT_VERSION" | cut -d. -f1)"
MINOR="$(echo "$CURRENT_VERSION" | cut -d. -f2)"
PATCH="$(echo "$CURRENT_VERSION" | cut -d. -f3)"

BUMP="patch"
for commit in $(git log --oneline --format=%s); do
  if [[ "$commit" == feat:* ]]; then
    BUMP="minor"
  elif [[ "$commit" == BREAKING:* ]] || [[ "$commit" == *"BREAKING CHANGE:"* ]]; then
    BUMP="major"
    break
  fi
done

case "$BUMP" in
  major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
  minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
  patch) PATCH=$((PATCH + 1)) ;;
esac

NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"
echo "$NEW_VERSION" > VERSION
git add VERSION
git commit -m "chore: release $NEW_VERSION"

git tag -a "v$NEW_VERSION" -m "Release v$NEW_VERSION"

echo "--- Release complete ---"
echo "Tag: v$NEW_VERSION"
git log --oneline --decorate --all -n 5
