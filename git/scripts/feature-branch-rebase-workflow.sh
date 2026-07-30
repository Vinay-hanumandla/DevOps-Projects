#!/usr/bin/env bash
# last_verified: 2026-07-30 · git n/a

# Demonstrates a feature branch workflow with interactive rebase.
# One way to practice this is to set up a temporary repo, create
# diverging history, and rebase the feature branch onto main.
# The docs also suggest using GIT_SEQUENCE_EDITOR to script rebase -i.

set -euo pipefail

LAB="/tmp/git-lab-$(date +%s)"
mkdir -p "$LAB"
cd "$LAB"

git init
git config user.email "learner@example.com"
git config user.name "Git Learner"

echo "v1" > readme.txt
git add readme.txt
git commit -m "initial commit on main"

git checkout -b feature/header
echo "## Header" > readme.txt
git add readme.txt
git commit -m "add header on feature branch"

echo -e "## Header\n\nBody text" > readme.txt
git add readme.txt
git commit -m "add body on feature branch"

git checkout main
echo "v2" > readme.txt
git add readme.txt
git commit -m "update readme on main"

GIT_SEQUENCE_EDITOR="true" git rebase main

echo "--- Commit graph after rebase ---"
git log --oneline --graph --all