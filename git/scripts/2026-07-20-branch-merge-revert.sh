#!/usr/bin/env bash
# last_verified: 2026-07-20 · git 2.43

# Practicing a basic branch → merge → revert cycle.
# I kept accidentally committing to main instead of a branch, so I made this
# to run through the flow deliberately until it stuck.

set -x

LAB="/tmp/git-lab-$(date +%s)"
mkdir -p "$LAB"
cd "$LAB" || exit

git init
git config user.email "learner@example.com"
git config user.name "Git Learner"

echo "v1" > readme.txt
git add readme.txt
git commit -m "initial"

# Branch off to add a feature — used -b to create and switch at once
git checkout -b feature/uppercase
echo "V1" > readme.txt
git add readme.txt
git commit -m "uppercase the content"

# Back to main, merge the feature in
git checkout main
git merge feature/uppercase --no-edit

# Oh no — I actually wanted the lowercase version. Revert it.
git revert --no-edit HEAD

git log --oneline --all
