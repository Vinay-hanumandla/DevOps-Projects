---
last_verified: 2026-07-28
tool_version: n/a
sources:
  - https://www.bmc.com/blogs/devops-containers/
  - https://skillions.in/devops-explained-in-2026-how-ci-cd-docker-kubernetes-accelerate-modern-software-development/
  - https://www.c-sharpcorner.com/article/how-to-implement-cicd-pipelines-for-modern-microservices-applications
---

# CI/CD Pipeline Concepts — companion requirements.txt notes

> Notes on what I learned about requirements.txt while working through the CI/CD pipeline primer. First-person, hands-on.

## What happened

The CI/CD primer showed a minimal pipeline for a Python service that includes `pip install -r requirements.txt` as a dependency-install stage. I ran through this locally to see what actually happens when a requirements file is missing or has a bad package name.

```bash
# Create a minimal requirements file
echo "requests==2.31.0" > requirements.txt
pip install -r requirements.txt
```

That worked cleanly. But when I intentionally changed `requests` to `requests-nonexistent`, the install failed fast — exactly the fail-fast behaviour the primer describes. The pipeline would stop at the install stage and never reach build or deploy.

## Got stuck on

The tricky part was pinning versions correctly. I wanted `requests` but didn't know the latest version off the top of my head. Using `requests==2.31.0` works, but if someone updates the file to `requests==99.0.0` (which doesn't exist), the pipeline breaks. I learned that `pip install -r requirements.txt` will abort on the first failed package — which is good for fail-fast, but means I need to verify versions before committing.

Another gotcha: requirements.txt doesn't handle transitive dependencies well on its own. When I added `requests`, pip also pulled in `urllib3`, `charset-normalizer`, and `idna` underneath it. The file grew quickly and I wasn't sure which dependencies were direct vs transitively required.

## What I'd try next

I want to learn `pip freeze > requirements.txt` to capture the full dependency tree after a working install, then compare it against my hand-edited file. That shows me the difference between a developer-edited requirements file (direct deps only) and a frozen one (everything).

I'd also like to try generating a lock file with `pip-compile` (from pip-tools) — it resolves transitive deps and pins exact versions, which is what most real CI/CD pipelines use to guarantee reproducible builds across environments.