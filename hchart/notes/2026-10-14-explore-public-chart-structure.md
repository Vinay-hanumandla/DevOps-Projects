---
last_verified: 2026-10-14
tool_version: n/a
sources: []
---

# Exploring a public chart's structure — what's there

I unpacked a public chart to see what files a real one ships with, beyond the primer's toy example.

## What I did

I unpacked a chart package. The top level had Chart.yaml, values.yaml, templates/ and charts/ folders, plus a README.md and a .helmignore I didn't expect.

## What was in each file

Chart.yaml was bigger than my toy version. It had an icon field, a keywords list, a home URL, a maintainers section, and a dependencies section. The dependencies listed other charts (like a database chart) that get pulled into charts/ at install time — that's how one chart depends on another.

values.yaml was organized into clear sections: one block per component (the app, the database subchart, ingress). Every value had a comment. The defaults were real, not placeholders.

templates/ had the usual deployment.yaml and service.yaml, plus a _helpers.tpl for shared snippets (naming, labels) and a tests/ folder with a smoke-check pod.

## Got stuck on

- .helmignore: I expected an empty file. It had half a dozen exclusions (.git/, *.swp, *.tgz). Didn't know charts ship with one by default.
- charts/ folder was empty. I thought I was missing something until I remembered dependencies get downloaded there by `helm dependency update`, not committed to the repo.

## What I'd try next

Run `helm dependency update` to populate charts/, then `helm template` to see rendered output without installing. I want to see how values flow into the templates.
