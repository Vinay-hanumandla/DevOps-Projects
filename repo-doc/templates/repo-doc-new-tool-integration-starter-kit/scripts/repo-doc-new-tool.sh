#!/usr/bin/env bash
# last_verified: 2026-10-19 · bash 5.3
#
# repo-doc-new-tool.sh
# Creates a new tool folder with the standard 9-category layout,
# seeds a primer stub, and registers the tool in the coverage script.

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: repo-doc-new-tool.sh <tool-name>

Creates a new tool folder under the repo root with the standard
9-category layout (notes/, docs/, scripts/, snippets/, configs/,
templates/, manifests/, dockerfiles/, notebooks/), adds a primer
stub at notes/0000-primer-<tool>.md, and updates the known-tool
list in repo-doc/scripts/2026-09-01-regenerate-coverage-tables.sh.

Example:
  repo-doc-new-tool.sh kustomize
EOF
}

if [[ $# -ne 1 ]]; then
  usage
  exit 1
fi

tool="$1"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
tool_dir="$repo_root/$tool"
coverage_script="$repo_root/repo-doc/scripts/2026-09-01-regenerate-coverage-tables.sh"

# Validate tool name: lowercase, alphanumeric + hyphen, no leading/trailing hyphen
if [[ ! "$tool" =~ ^[a-z][a-z0-9-]*[a-z0-9]$ ]]; then
  echo "Error: tool name must be lowercase alphanumeric with hyphens, no leading/trailing hyphen" >&2
  exit 1
fi

# Check if tool already exists
if [[ -d "$tool_dir" ]]; then
  echo "Error: tool directory $tool_dir already exists" >&2
  exit 1
fi

# Check if coverage script exists
if [[ ! -f "$coverage_script" ]]; then
  echo "Error: coverage script not found at $coverage_script" >&2
  exit 1
fi

echo "Creating tool folder: $tool"

# Create the 9 standard category directories
categories=(notes docs scripts snippets configs templates manifests dockerfiles notebooks)
for cat in "${categories[@]}"; do
  mkdir -p "$tool_dir/$cat"
  echo "  Created $tool_dir/$cat/"
done

# Create primer stub
primer_file="$tool_dir/notes/0000-primer-$tool.md"
today=$(date +%Y-%m-%d)
cat >"$primer_file" <<EOF
---
last_verified: $today
tool_version: n/a
sources: []
---

# ${tool^} — quick primer

> First-day notes for someone who's never used ${tool^}. Personal voice, plain language.

## What is it?

<1–2 paragraphs. Define ${tool^}. What problem space does it sit in? Compare to a tool the reader probably already knows.>

## What does it do?

<2–4 sentences on the core function. Concrete actions.>

## Why does it exist?

<What problem it solves. What the workflow was like before this tool existed, or how people did it without it. Who actually uses it day-to-day.>

## Key terminology

<5–10 core terms a beginner will hit in the first week. Format each as a bullet with a quick concrete example.>
- **<Term>** — <one-sentence definition>. Example: <one-line concrete use>.
- **<Term>** — <one-sentence definition>. Example: <one-line concrete use>.

## A tiny example

<The smallest "hello world" that shows the tool in action. 3–10 lines of code or commands in a fenced code block. Use the tool's primary interaction language. Add a one-line caption explaining what the example does.>

## What I'll cover next

<2–3 sentences on what tasks I plan to tackle after this primer — orient the future-me. Don't enumerate; just point at the direction.>
EOF

echo "  Created primer stub: $primer_file"

# Update the coverage script's tools array
# Find the line: tools=(ansible bash docker gha git grafana helm jenkins k8s prom python tf repo-doc)
# Insert the new tool in alphabetical order
tools_line=$(grep -n '^tools=(' "$coverage_script" | head -1 | cut -d: -f1)
if [[ -z "$tools_line" ]]; then
  echo "Error: could not find tools array in coverage script" >&2
  exit 1
fi

# Extract current tools, add new one, sort, and rebuild the line
current_tools=$(sed -n "${tools_line}p" "$coverage_script" | sed -E 's/^tools=\((.*)\)$/\1/')
# Convert to array, add new tool, sort
IFS=' ' read -ra tools_array <<<"$current_tools"
tools_array+=("$tool")
# Sort alphabetically (bash 4+)
mapfile -t sorted_tools < <(printf '%s\n' "${tools_array[@]}" | sort)
new_tools_line="tools=(${sorted_tools[*]})"

# Replace the line in the coverage script
sed -i "${tools_line}s/.*/$new_tools_line/" "$coverage_script"
echo "  Updated coverage script tools array (added '$tool' in alphabetical order)"

echo ""
echo "Done! New tool '$tool' created at $tool_dir"
echo "Next steps:"
echo "  1. Edit the primer stub at $primer_file"
echo "  2. Run the coverage script to verify: bash $coverage_script $repo_root"
echo "  3. Add your first dated note, script, or doc under $tool_dir/"