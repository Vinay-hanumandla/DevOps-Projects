---
last_verified: 2026-09-10
tool_version: n/a
sources: []
---

# Repo: task quickstart — what tripped me up

> Following the repo-doc primer and getting the tooling running for the first time. Notes on the parts that were confusing or took more effort than expected.

## What I tried

I followed the primer's instructions to run the coverage-table regeneration script and understand the tool layout. The goal was to get comfortable adding a new file and having the coverage table update automatically.

## What worked

The coverage table script ran without issues from the repo root:

```bash
bash repo-doc/scripts/2026-09-01-regenerate-coverage-tables.sh .
```

It printed the expected Markdown grid showing file counts per tool per category. That part was smooth — no dependencies, no config, just `bash` and `find`.

## What tripped me up

**1. The script expects the repo root as an argument.** The primer mentions running it from the repo root, but I tried running it from inside the `repo-doc/` directory first (`bash scripts/2026-09-01-regenerate-coverage-tables.sh`) and got errors because it could not find any tool folders. The script walks the directory tree looking for folders that match the tool naming convention, and it needs to start from the root to find all of them.

**2. The "tool folder" concept is implicit.** The script detects tool folders by looking for directories that contain category subdirectories (`notes/`, `docs/`, `scripts/`, etc.). It does not read a manifest or config file — it walks the tree and counts. This means a stray `notes/` directory at the wrong level could be misidentified as a tool folder. In practice the layout is consistent enough that this has not happened, but it is worth knowing the detection is heuristic.

**3. The output goes to stdout, not to a file.** The script prints the Markdown table to the terminal. I had to copy-paste it into `README.md` manually. The next step would be to pipe it to a file or have the script update the README in place, but that introduces its own risks (overwriting other changes). For now, copy-paste is the safer workflow.

**4. Category subdirectory names are fixed.** The primer lists them (`notes/`, `docs/`, `scripts/`, `snippets/`, `configs/`, `templates/`, `manifests/`, `dockerfiles/`, `notebooks/`), but there is no validation that a new file goes in the correct subdirectory. If I put a `.py` file in `docs/` instead of `scripts/`, the coverage count would still register it as a "docs" file. The tooling counts by directory, not by file extension.

**5. The index regeneration is separate.** The primer mentions per-tool `index.md` or `coverage.md` pages, but the script I ran only produces the top-level coverage table. Regenerating the per-tool index pages is apparently a different step that I have not found yet. This is the third table the primer mentions needing to stay in sync.

## What I would do differently

- Run the script from the repo root on the first try.
- Check the output before pasting it into the README, because the script counts everything it finds — including files I may have put in the wrong place.
- Keep the tool folder layout consistent: every tool gets the same set of category subdirectories, even if some are empty, so the coverage table stays predictable.
