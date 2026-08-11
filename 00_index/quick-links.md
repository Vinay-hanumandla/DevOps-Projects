# Quick Links

## I need to...

### Get started with Ansible
- [Ansible primer](../ansible/notes/0000-primer-ansible.md) — what Ansible is, control/managed nodes, playbooks, inventory, modules, tasks, and roles
- [Installing Ansible and running my first command](../ansible/notes/2026-08-10-install-ansible-and-run-first-command.md) — pipx install, first ping command, and the PEP 668 trap
- [First ping playbook](../ansible/configs/2026-08-10-first-ping-playbook.yaml) — minimal playbook to verify SSH connectivity to managed hosts

### Get started with Bash
- [Bash primer](../bash/notes/0000-primer-bash.md) — what Bash is, key terminology, and a tiny example
- [Install Bash and first script](../bash/notes/2026-07-18-install-bash-and-first-script.md) — install check, first .sh file, and permission gotcha
- [Bash guide — trip-ups](../bash/notes/2026-07-23-bash-guide-trip-ups.md) — quoting, word splitting, exit codes, and trap

### Write and run a Bash script
- [Hello world with argument handling](../bash/scripts/2026-07-18-first-hello-world.sh) — a minimal script that checks for arguments
- [Safe Bash template](../bash/scripts/2026-07-23-safe-bash-template.sh) — a reusable skeleton with `set -euo pipefail`
- [Companion hello script](../bash/scripts/2026-07-27-companion-hello.sh) — companion script for the hello-world pattern with argument handling and strict mode
- [Companion test script](../bash/scripts/2026-07-27-companion-test.sh) — test companion that exercises the safe Bash template patterns
- [System report tool](../bash/scripts/system-report-tool.sh) — directory-based system report tool with text and JSON output
- [Log rotation and retention](../bash/scripts/log-rotation-retention.sh) — compresses and prunes log files older than a threshold with gzip and age-based retention

### Write robust Bash
- [Robust Bash scripting](../bash/docs/2026-07-23-robust-bash-scripts.md) — strict mode, error handling, and safe defaults
- [Strict mode and trap patterns](../bash/docs/strict-mode-trap-patterns.md) — notes on integrating set -euo pipefail and trap-based cleanup into a script workflow
- [Debugging and profiling with set -x and trace traps](../bash/docs/debug-and-profile-with-set-x-and-trace-traps.md) — trace a failing script to its line and time functions with DEBUG/RETURN traps

### Get started with Docker
- [Docker primer](../docker/notes/0000-primer-docker.md) — what Docker is, images vs containers, and a minimal workflow
- [Docker quickstart trip-ups](../docker/notes/2026-07-13-docker-quickstart-trip-ups.md) — what to expect and where beginners get stuck
- [Docker follow-up trip-ups](../docker/notes/2026-07-15-docker-quickstart-trip-ups.md) — more gotchas after the initial run-through
- [Install Docker](../docker/notes/2026-07-19-install-docker.md) — check installation, verify the daemon is running
- [Docker trip-ups after the initial run-through](../docker/notes/2026-08-06-docker-quickstart-trip-ups.md) — more gotchas after getting containers running
- [Hello-world container](../docker/scripts/2026-07-19-first-hello-world.sh) — pull and run the hello-world image to verify Docker works

### Build a container image
- [Minimal non-root Dockerfile](../docker/dockerfiles/2026-07-17-minimal-image-tagged-nonroot.Dockerfile) — multi-stage build to a distroless, non-root runtime

### Run a container
- [Run container with port map](../docker/scripts/2026-07-16-run-container-port-map.sh) — run a tagged image, map a port, verify, and tear down
- [Run nginx with port map](../docker/scripts/2026-07-18-first-port-mapped-container.sh) — run nginx, map a port, verify, and tear down

### Get started with Git
- [Git primer](../git/notes/0000-primer-git.md) — what Git is, key concepts, and a minimal workflow
- [Git quickstart trip-ups](../git/notes/2026-07-13-git-quickstart-trip-ups.md) — first contact with Git and where it tripped me up
- [Git follow-up trip-ups](../git/notes/2026-07-15-git-quickstart-trip-ups.md) — more first-contact gotchas on the second pass
- [Install Git](../git/notes/2026-07-20-install-git.md) — check installation and configure user identity
- [First repo lifecycle](../git/scripts/2026-07-20-first-repo.sh) — init, add, commit, status in a minimal example

### Undo and fix a Git mistake
- [Undo, stage, commit, push](../git/notes/2026-07-13-undo-stage-commit-push.md) — unstage, discard, revert, and safely rewrite a local commit
- [Undo follow-up](../git/notes/2026-07-15-undo-stage-commit-push.md) — more undo patterns: stash, amend after push, recovering lost work

### Branch, merge, and revert
- [Branch, merge, revert](../git/scripts/2026-07-20-branch-merge-revert.sh) — create branches, merge them, and undo a merge
- [Feature branch rebase workflow](../git/scripts/feature-branch-rebase-workflow.sh) — rebase a feature branch onto main and keep history clean

### Use interactive rebase effectively
- [Interactive rebase vs merge commit](../git/docs/interactive-rebase-vs-merge-commit.md) — reference guide comparing the two core Git collaboration strategies
- [Rebase-based vs merge-based release workflows](../git/docs/rebase-based-vs-merge-based-release-workflows.md) — comparing rebase and merge strategies for release branches

### Automate releases with Git
- [Semantic release automation](../git/scripts/semantic-release-automation.sh) — demonstrates a minimal semantic-release-like flow using Git tags and version bumps

### Set up Git hooks
- [How I wired Git hooks into my local dev workflow](../git/docs/how-i-wired-git-hooks-into-my-local-dev-workflow.md) — notes on automating Git hooks for consistent local practices
- [Install Git hooks](../git/hooks/install.sh) — one-command setup for pre-commit and hook utilities in the local repo

### Map out the Git folder
- [Git — my first file index](../git/docs/2026-08-10-git-index.md) — cataloguing the Git folder into a per-category coverage table

### Get started with Grafana
- [Grafana primer](../grafana/notes/0000-primer-grafana.md) — what Grafana is, dashboards vs panels, and a minimal workflow
- [Install Grafana](../grafana/notes/2026-08-06-install-grafana.md) — install check and first web UI login
- [First dashboard config](../grafana/configs/2026-08-06-first-dashboard.yaml) — a minimal Grafana dashboard JSON config

### Get started with Helm
- [Helm primer](../helm/notes/0000-primer-helm.md) — what Helm is, charts and templating, and a minimal workflow
- [Install Helm and run version command](../helm/notes/2026-07-31-install-helm-run-version.md) — install check, version verification, and adding the stable chart repository
- [Explore Helm chart repo and chart structure](../helm/notes/2026-08-08-explore-helm-chart-repo.md) — notes on Helm chart repo anatomy and chart folder structure

### Deploy with Helm
- [Deploy first chart](../helm/snippets/2026-07-31-deploy-first-chart.sh) — install and manage a Helm chart in a local or test cluster
- [First values override](../helm/configs/2026-08-08-first-values-override.yaml) — minimal Helm values override with replica count and image tag
- [Helm — coverage check](../helm/docs/2026-08-10-helm-coverage.md) — comparing the Helm folder against the manifest and fixing the counts

### Get started with Jenkins
- [Jenkins primer](../jenkins/notes/0000-primer-jenkins.md) — what Jenkins is, jobs, pipelines, nodes, and plugins
- [Installing Jenkins and opening the web UI](../jenkins/notes/2026-08-11-install-jenkins-and-open-web-ui.md) — install, initial admin password, and first login
- [Hello-world pipeline](../jenkins/snippets/2026-08-11-hello-world-pipeline.groovy) — a minimal declarative pipeline job to paste in and hit Build Now

### Get started with Kubernetes
- [Kubernetes primer](../k8s/notes/0000-primer-kubernetes.md) — first-contact notes for Kubernetes concepts and kubectl basics
- [Install Minikube and run kubectl version](../k8s/scripts/2026-08-03-install-minikube-and-run-kubectl-version.sh) — install Minikube, start a cluster, and verify kubectl
- [Explore kubectl CLI](../k8s/notes/2026-08-03-explore-kubectl-cli.md) — kubectl CLI exploration notes with common commands and output explanations
- [Kubernetes quickstart tripped up](../k8s/notes/2026-08-04-kubernetes-quickstart-tripped-up.md) — more kubectl gotchas on the second pass

### Inspect Kubernetes resources
- [Inspecting pods, services, and events](../k8s/docs/2026-08-04-inspecting-pods-services-events.md) — kubectl commands for inspecting cluster resources and their events
- [Minimal deployment and service manifest](../k8s/manifests/2026-08-04-minimal-deployment-and-service.yaml) — a minimal Kubernetes Deployment and Service YAML

### Get started with Prometheus
- [Prometheus primer](../prom/notes/0000-primer-prometheus.md) — what Prometheus is, metrics types, and a minimal workflow
- [Install and explore web UI](../prom/notes/2026-08-07-install-and-explore-web-ui.md) — install check and first web UI exploration
- [First scrape target](../prom/configs/2026-08-07-first-scrape-target.yaml) — a minimal Prometheus scrape target config

### Get started with Python
- [Python primer](../python/notes/0000-primer-python.md) — variables, types, functions, lists, dicts, venv, and pip
- [Python modules, packages, and imports](../python/docs/2026-08-04-python-modules-packages-imports.md) — module and package mechanics, import resolution, and common pitfalls
- [Python functions and modules](../python/notes/2026-08-04-python-functions-modules.md) — function definitions, module organisation, and import patterns

### Write and run a Python script
- [Create venv and run](../python/scripts/2026-07-22-create-venv-and-run.py) — end-to-end virtual-environment setup and a runner inside it
- [Minimal file processing](../python/scripts/2026-08-04-minimal-file-processing.py) — read, process, and write files with Python
- [First script — variables and types](../python/snippets/2026-07-22-first-script-variables-types.py) — declare variables, inspect types, and print mixed-type lists

### Get started with Terraform
- [Terraform primer](../tf/notes/0000-primer-terraform.md) — what Terraform is, providers, state, and a minimal workflow
- [Install Terraform and run first version command](../tf/notes/2026-07-26-install-terraform-and-run-first-version-command.md) — check installation and run the first Terraform command
- [First Terraform local file resource](../tf/configs/2026-07-26-first-terraform-local-file-resource.hcl) — a minimal Terraform config that creates a local file
- [Terraform project structure](../tf/docs/2026-08-06-terraform-project-structure.md) — how to organise Terraform configs and modules
- [First Terraform provider resource](../tf/configs/2026-08-06-first-terraform-provider-resource.hcl) — a Terraform config that creates a provider resource
- [Minimal provider resource](../tf/configs/2026-08-08-minimal-provider-resource.hcl) — a minimal Terraform config with provider and resource blocks
- [Terraform init, plan, apply](../tf/scripts/2026-08-08-tf-init-plan-apply.sh) — end-to-end Terraform workflow script for initialising, planning, and applying
- [Terraform — coverage check](../tf/docs/2026-08-11-terraform-coverage.md) — comparing the tf folder against the coverage table and fixing the counts

### Understand a DevOps concept before touching a tool
- [Linux & CLI Fundamentals](../docs/concepts/linux-cli-fundamentals/0000-primer-linux-cli-fundamentals.md) — the shell, processes, and filesystem basics everything leans on
- [Networking Fundamentals](../docs/concepts/networking-fundamentals/0000-primer-networking-fundamentals.md) — ports, addresses, and how containers reach the host
- [Containerization Concepts](../docs/concepts/containerization-concepts/0000-primer-containerization-concepts.md) — images, containers, and why they exist
- [Version Control & Git Workflow](../docs/concepts/version-control-git-workflow/0000-primer-version-control-git-workflow.md) — the ideas behind commits, branches, and remotes
- [CI/CD Pipeline Concepts](../docs/concepts/ci-cd-pipeline-concepts/0000-primer-ci-cd-pipeline-concepts.md) — build, test, deploy, and why it's automated
- [Gate-before-merge with branch protection](../docs/concepts/ci-cd-pipeline-concepts/gate-before-merge-branch-protection.md) — how branch protection rules and pipeline gates combine to block broken merges
- [Infrastructure as Code Principles](../docs/concepts/infrastructure-as-code-principles/0000-primer-infrastructure-as-code-principles.md) — describing infrastructure in files, not by hand
- [Scripting & Automation Philosophy](../docs/concepts/scripting-automation-philosophy/0000-primer-scripting-automation-philosophy.md) — when to reach for a script instead of doing it manually
- [Combining scripting with CI/CD pipeline automation](../docs/concepts/scripting-automation-philosophy/combining-scripting-with-cicd-pipeline-automation.md) — keeping logic in scripts and sequencing in the pipeline YAML
- [Combining observability with containerization](../docs/concepts/observability-monitoring-concepts/combining-observability-with-containerization.md) — adapting logs, metrics, and traces for containerized environments
- [Observability & Monitoring Concepts](../docs/concepts/observability-monitoring-concepts/0000-primer-observability-monitoring-concepts.md) — knowing what your systems are doing in production
- [Combining containerization with CI/CD: multi-stage build patterns](../docs/concepts/containerization-concepts/combining-containerization-with-ci-cd-multi-stage-build-patterns.md) — notes on combining containerization with CI/CD using multi-stage builds
- [Companion readme for version control](../docs/concepts/version-control-git-workflow/notes/2026-07-28-companion-readme.md) — companion notes on Git workflow practices

### Practice a concept hands-on
- [CI/CD stage simulation](../docs/concepts/ci-cd-pipeline-concepts/scripts/2026-07-19-pipeline-stage-sim.sh) — a pure-Bash build→test→deploy pipeline with fail-fast gating
- [Artifact promotion](../docs/concepts/ci-cd-pipeline-concepts/snippets/2026-07-20-artifact-promotion.py) — promote a build artifact across pipeline stages with an audit trail
- [Pipeline metrics and health dashboards](../docs/concepts/ci-cd-pipeline-concepts/notebooks/pipeline-metrics-and-health-dashboards.ipynb) — CI/CD observability notebook with DORA metrics and pipeline health scoring
- [Container lifecycle inspection](../docs/concepts/containerization-concepts/scripts/2026-07-20-container-lifecycle-inspection.sh) — inspect running and stopped containers using the Docker API
- [Container observability: Prometheus node exporter](../docs/concepts/containerization-concepts/scripts/containerization-observability-prometheus-node-exporter.sh) — run a Prometheus node exporter container to collect host-level metrics
- [Image manifest parser](../docs/concepts/containerization-concepts/snippets/2026-07-22-image-manifest-parser.py) — parse container image manifests and extract layer metadata
- [IaC idempotency check](../docs/concepts/infrastructure-as-code-principles/scripts/2026-07-22-iac-idempotency-check.sh) — verify that a provisioning step produces the same result on repeat runs
- [Generating Docker Compose configs](../docs/concepts/infrastructure-as-code-principles/scripts/generating-docker-compose-configs.sh) — generate Docker Compose configs from IaC definitions
- [Declarative state diff](../docs/concepts/infrastructure-as-code-principles/snippets/2026-07-22-declarative-state-diff.py) — diff declarative state to detect drift
- [File permissions and processes](../docs/concepts/linux-cli-fundamentals/scripts/2026-07-24-linux-file-permissions-and-process-management.sh) — inspect and modify Linux file permissions, then list and filter running processes
- [Subprocess wrapper](../docs/concepts/linux-cli-fundamentals/snippets/2026-07-24-subprocess-wrapper.py) — run a command and capture stdout/stderr/return code from Python
- [Exploring connectivity with command-line tools](../docs/concepts/linux-cli-fundamentals/notebooks/exploring-connectivity-with-command-line-tools.ipynb) — notebook exploring network connectivity and DNS resolution from the CLI
- [Network connectivity check](../docs/concepts/networking-fundamentals/scripts/2026-07-25-practice-network-connectivity-dns-port-inspection.sh) — test TCP connectivity to a host:port and diagnose why it's unreachable
- [Networking observability health check](../docs/concepts/networking-fundamentals/scripts/networking-observability-health-check.sh) — check service health and network observability
- [Network interface and routing inspection](../docs/concepts/networking-fundamentals/scripts/2026-08-05-network-interface-and-routing-inspection.sh) — inspect network interfaces and routing tables
- [Socket connection tester](../docs/concepts/networking-fundamentals/snippets/2026-07-26-socket-connection-tester.py) — Python snippet that tests TCP socket connectivity and reports the result
- [Observability exercises](../docs/concepts/observability-monitoring-concepts/scripts/2026-08-06-observability-exercises.sh) — hands-on exercises for observability concepts
- [CI/CD pipeline metric collection probes](../docs/concepts/observability-monitoring-concepts/scripts/observability-cicd-pipeline-metric-collection-probes.sh) — collects CI/CD pipeline metrics and exports them to a Prometheus pushgateway endpoint
- [Applying observability in DevOps](../docs/concepts/observability-monitoring-concepts/snippets/2026-08-07-applying-observability-in-devops.py) — Python snippet that extracts RED-method golden signals from request logs

### Practice DevOps scripting and automation
- [Scripting automation exercises](../docs/concepts/scripting-automation-philosophy/scripts/2026-08-07-scripting-automation-exercises.sh) — hands-on practice for DRY helpers, idempotency, and exit codes from the scripting philosophy primer
- [Terraform plan/apply idempotent script](../docs/concepts/scripting-automation-philosophy/scripts/terraform-plan-apply-idempotent.sh) — validate → plan → apply workflow where apply consumes a reviewed saved plan
- [Applying scripting in DevOps](../docs/concepts/scripting-automation-philosophy/snippets/2026-08-07-applying-scripting-in-devops.py) — Python snippet that parses a host inventory and applies role/env-based deploy actions
- [Applying version control in DevOps](../docs/concepts/version-control-git-workflow/snippets/2026-08-11-applying-version-control-in-devops.py) — turn a branch's commit history into a release changelog via conventional commits
- [Git workflow practice exercises](../docs/concepts/version-control-git-workflow/scripts/2026-08-07-git-exercises.sh) — read-only script for inspecting repo state, branch, history, and upstream tracking

### Get started with GitHub Actions
- [GitHub Actions primer](../gha/notes/0000-primer-gha.md) — what GitHub Actions is, workflows vs jobs, and a minimal workflow
- [Install GitHub CLI](../gha/notes/2026-08-05-install-gh-cli.md) — check installation and configure the gh CLI
- [First workflow config](../gha/configs/2026-08-05-first-workflow.yaml) — a first GitHub Actions workflow configuration
- [Minimal CI workflow](../gha/configs/2026-08-06-minimal-ci-workflow.yaml) — a minimal GitHub Actions workflow for CI
- [GitHub Actions quickstart trip-ups](../gha/notes/2026-08-06-github-actions-quickstart-trip-ups.md) — what to expect and where beginners get stuck
- [How I learned to read workflow logs and debug failures](../gha/docs/2026-08-06-how-i-learned-to-read-workflow-logs-and-debug-failures.md) — debugging failed GitHub Actions runs

### Keep the repo's own docs in sync
- [Repo — reconcile coverage tables with on-disk counts](../repo-doc/docs/2026-08-08-reconcile-coverage-tables.md) — how I kept the README coverage table and Git index honest against what's actually on disk
