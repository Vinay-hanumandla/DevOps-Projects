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
- [Debug and profile with set -x and trace traps](../bash/docs/debug-and-profile-with-set-x-and-trace-traps.md) — using Bash's execution trace and DEBUG trap for profiling and debugging
- [Integrating Bash with Git](../bash/docs/integrating-bash-with-git.md) — fail-fast, re-runnable patterns for release scripts that touch git

### Run Bash in a container
- [Strict-mode runner image](../bash/dockerfiles/strict-mode-runner.Dockerfile) — a minimal Debian image that wraps Bash in `set -euo pipefail` under an unprivileged user

### Scaffold a Bash project that runs in Docker
- [Bash + Docker toolchain scaffold](../bash/templates/bash-docker-scaffold/README.md) — a starting layout where shellcheck, shfmt, and bats all run in a toolchain container, keeping the host clean

### Scaffold a multi-container Bash stack with health checks
- [Bash + Docker health-check scaffold](../bash/templates/bash-docker-healthcheck-scaffold/README.md) — a small running stack (cache + web + worker) whose startup ordering is wired through Docker health checks
- [Health-check stack — docker-compose.yml](../bash/templates/bash-docker-healthcheck-scaffold/docker-compose.yml) — the `depends_on: condition: service_healthy` ordering between services
- [Health-check stack — up.sh](../bash/templates/bash-docker-healthcheck-scaffold/scripts/up.sh) — brings the stack up and waits for every service to report `healthy`

### Compare Bash log-rotation approaches
- [Comparing log rotation approaches](../bash/notebooks/comparing-log-rotation-approaches.ipynb) — notebook comparing inotifywait vs cron-driven polling for log rotation

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

### Compose multi-service stacks
- [Multi-service Docker Compose config](../docker/manifests/2026-08-17-multi-service-docker-compose.yaml) — web app, cache, and worker on the default network with `depends_on`

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
- [Git PR helper](../git/scripts/git-pr-helper.sh) — reusable helper for creating, deleting, and opening PRs for feature branches

### Use interactive rebase effectively
- [Interactive rebase vs merge commit](../git/docs/interactive-rebase-vs-merge-commit.md) — reference guide comparing the two core Git collaboration strategies
- [Rebase-based vs merge-based release workflows](../git/docs/rebase-based-vs-merge-based-release-workflows.md) — comparing rebase and merge strategies for release branches
- [Rebase vs merge at scale](../git/docs/rebase-vs-merge-at-scale.md) — how the two strategies behave once a repo crosses hundreds of contributors and long-lived release branches

### Tag and push a Docker image from Git history
- [Git — tagging Docker images from git describe](../git/docs/git-describe-image-tags-registry.md) — deriving traceable image tags from git history and pushing to a registry

### Trigger a pipeline from Git events
- [CI/CD pipeline trigger manifest](../git/manifests/ci-cd-pipeline-trigger.yaml) — maps push, tag, and merge-request events to build → test → deploy jobs with `workflow.rules`

### Automate releases with Git
- [Release workflow scaffold README](../git/templates/release-workflow/README.md) — copy-in layout for tag-driven releases with make targets and shell helpers
- [Release workflow — release.sh](../git/templates/release-workflow/scripts/release.sh) — bump VERSION, commit, annotated tag, and push, refusing to run on a dirty tree
- [Release workflow — changelog.sh](../git/templates/release-workflow/scripts/changelog.sh) — print a conventional-commit summary since a release tag
- [Release workflow — verify-release.sh](../git/templates/release-workflow/scripts/verify-release.sh) — end-to-end proof that runs in a throwaway repo and cleans up after itself
- [Semantic release automation](../git/scripts/semantic-release-automation.sh) — demonstrates a minimal semantic-release-like flow using Git tags and version bumps
- [Changelog from conventional commits](../git/scripts/changelog-from-conventional-commits.sh) — reusable helper that buckets commit subjects by type into a Markdown changelog
- [Release-readiness commit inventory](../docs/concepts/version-control-git-workflow/snippets/2026-08-20-release-branch-commit-check.py) — lists commits on `main` that have not reached the release branch, using the `release..main` range instead of memory

### Set up Git hooks
- [How I wired Git hooks into my local dev workflow](../git/docs/how-i-wired-git-hooks-into-my-local-dev-workflow.md) — notes on automating Git hooks for consistent local practices
- [Install Git hooks](../git/hooks/install.sh) — one-command setup for pre-commit and hook utilities in the local repo

### Map out the Git folder
- [Git — my first file index](../git/docs/2026-08-10-git-index.md) — cataloguing the Git folder into a per-category coverage table

### Get started with Grafana
- [Grafana primer](../grafana/notes/0000-primer-grafana.md) — what Grafana is, dashboards vs panels, and a minimal workflow
- [Install Grafana](../grafana/notes/2026-08-06-install-grafana.md) — install check and first web UI login
- [First dashboard config](../grafana/configs/2026-08-06-first-dashboard.yaml) — a minimal Grafana dashboard JSON config
- [Create dashboard via API](../grafana/snippets/2026-08-22-create-dashboard.sh) — creates a dashboard with a stat panel using curl and the Grafana HTTP API
- [List dashboards](../grafana/snippets/2026-08-19-list-dashboards.sh) — a shell helper that enumerates dashboards via the Grafana API

### Get started with Helm
- [Helm primer](../helm/notes/0000-primer-helm.md) — what Helm is, charts and templating, and a minimal workflow
- [Install Helm and run version command](../helm/notes/2026-07-31-install-helm-run-version.md) — install check, version verification, and adding the stable chart repository
- [Install Helm with package manager](../helm/notes/2026-08-18-install-helm-with-package-manager.md) — package-manager install, version check, and shell completion setup
- [Following the Helm quickstart](../helm/notes/2026-08-19-following-helm-quickstart.md) — walked through the official quickstart: chart scaffold, install, and lifecycle commands
- [Explore Helm chart repo and chart structure](../helm/notes/2026-08-08-explore-helm-chart-repo.md) — notes on Helm chart repo anatomy and chart folder structure

### Deploy with Helm
- [Deploy first chart](../helm/snippets/2026-07-31-deploy-first-chart.sh) — install and manage a Helm chart in a local or test cluster
- [First values override](../helm/configs/2026-08-08-first-values-override.yaml) — minimal Helm values override with replica count and image tag
- [First chart template](../helm/manifests/2026-08-14-first-chart-template.yaml) — a minimal trimmed Deployment template with `.Values.*` placeholders
- [Dev values override](../helm/configs/2026-08-20-dev-values.yaml) — per-environment values for a dev Helm release
- [Staging values override](../helm/configs/2026-08-20-staging-values.yaml) — per-environment values for a staging Helm release
- [Prod values override](../helm/configs/2026-08-20-prod-values.yaml) — per-environment values for a production Helm release
- [Helm — coverage check](../helm/docs/2026-08-10-helm-coverage.md) — comparing the Helm folder against the manifest and fixing the counts

### Get started with Jenkins
- [Jenkins primer](../jenkins/notes/0000-primer-jenkins.md) — first-day notes for Jenkins: jobs, pipelines, nodes, executors, plugins, and workspaces
- [Install Jenkins and open web UI](../jenkins/notes/2026-08-11-install-jenkins-and-open-web-ui.md) — install check, first web UI login, and creating a hello-world pipeline job
- [Hello world pipeline](../jenkins/snippets/2026-08-11-hello-world-pipeline.groovy) — a minimal declarative Jenkins pipeline snippet

### Get started with Kubernetes
- [Kubernetes primer](../k8s/notes/0000-primer-kubernetes.md) — first-contact notes for Kubernetes concepts and kubectl basics
- [Install Minikube and run kubectl version](../k8s/scripts/2026-08-03-install-minikube-and-run-kubectl-version.sh) — install Minikube, start a cluster, and verify kubectl
- [Explore kubectl CLI](../k8s/notes/2026-08-03-explore-kubectl-cli.md) — kubectl CLI exploration notes with common commands and output explanations
- [Kubernetes quickstart tripped up](../k8s/notes/2026-08-04-kubernetes-quickstart-tripped-up.md) — more kubectl gotchas on the second pass

### Inspect Kubernetes resources
- [Inspecting pods, services, and events](../k8s/docs/2026-08-04-inspecting-pods-services-events.md) — kubectl commands for inspecting cluster resources and their events
- [Minimal deployment and service manifest](../k8s/manifests/2026-08-04-minimal-deployment-and-service.yaml) — a minimal Kubernetes Deployment and Service YAML
- [First deployment config](../k8s/configs/2026-08-22-first-deployment.yaml) — a minimal nginx Deployment with resource requests and limits
- [List cluster resources](../k8s/snippets/2026-08-19-list-cluster-resources.sh) — a shell helper that walks common resource types with kubectl

### Get started with Prometheus
- [Prometheus primer](../prom/notes/0000-primer-prometheus.md) — what Prometheus is, metrics types, and a minimal workflow
- [Install and explore web UI](../prom/notes/2026-08-07-install-and-explore-web-ui.md) — install check and first web UI exploration
- [First scrape target](../prom/configs/2026-08-07-first-scrape-target.yaml) — a minimal Prometheus scrape target config
- [First PromQL query](../prom/snippets/2026-08-19-first-promql-query.sh) — a shell helper that runs a basic PromQL query against a Prometheus server

### Get started with Python
- [Python primer](../python/notes/0000-primer-python.md) — variables, types, functions, lists, dicts, venv, and pip
- [Python modules, packages, and imports](../python/docs/2026-08-04-python-modules-packages-imports.md) — module and package mechanics, import resolution, and common pitfalls
- [Python functions and modules](../python/notes/2026-08-04-python-functions-modules.md) — function definitions, module organisation, and import patterns
- [Python quickstart gotchas](../python/notes/2026-08-22-python-quickstart-gotchas.md) — notes on venv activation, indentation, f-strings, and REPL vs script mode

### Write and run a Python script
- [Create venv and run](../python/scripts/2026-07-22-create-venv-and-run.py) — end-to-end virtual-environment setup and a runner inside it
- [Minimal file processing](../python/scripts/2026-08-04-minimal-file-processing.py) — read, process, and write files with Python
- [Config file reader](../python/snippets/2026-08-22-config-file-reader.py) — reads and pretty-prints a YAML config using PyYAML
- [First script — variables and types](../python/snippets/2026-07-22-first-script-variables-types.py) — declare variables, inspect types, and print mixed-type lists

### Get started with Terraform
- [Terraform primer](../tf/notes/0000-primer-terraform.md) — what Terraform is, providers, state, and a minimal workflow
- [Install Terraform and run first version command](../tf/notes/2026-07-26-install-terraform-and-run-first-version-command.md) — check installation and run the first Terraform command
- [First Terraform local file resource](../tf/configs/2026-07-26-first-terraform-local-file-resource.hcl) — a minimal Terraform config that creates a local file
- [Terraform project structure](../tf/docs/2026-08-06-terraform-project-structure.md) — how to organise Terraform configs and modules
- [First Terraform provider resource](../tf/configs/2026-08-06-first-terraform-provider-resource.hcl) — a Terraform config that creates a provider resource
- [Minimal provider resource](../tf/configs/2026-08-08-minimal-provider-resource.hcl) — a minimal Terraform config with provider and resource blocks
- [Terraform init, plan, apply](../tf/scripts/2026-08-08-tf-init-plan-apply.sh) — end-to-end Terraform workflow script for initialising, planning, and applying
- [Terraform coverage check](../tf/docs/2026-08-11-terraform-coverage.md) — reconciling the Terraform folder against the manifest and fixing the counts

### Understand a DevOps concept before touching a tool
- [Linux & CLI Fundamentals](../docs/concepts/linux-cli-fundamentals/0000-primer-linux-cli-fundamentals.md) — the shell, processes, and filesystem basics everything leans on
- [Networking Fundamentals](../docs/concepts/networking-fundamentals/0000-primer-networking-fundamentals.md) — ports, addresses, and how containers reach the host
- [Containerization Concepts](../docs/concepts/containerization-concepts/0000-primer-containerization-concepts.md) — images, containers, and why they exist
- [Version Control & Git Workflow](../docs/concepts/version-control-git-workflow/0000-primer-version-control-git-workflow.md) — the ideas behind commits, branches, and remotes
- [CI/CD Pipeline Concepts](../docs/concepts/ci-cd-pipeline-concepts/0000-primer-ci-cd-pipeline-concepts.md) — build, test, deploy, and why it's automated
- [Gate-before-merge with branch protection](../docs/concepts/ci-cd-pipeline-concepts/gate-before-merge-branch-protection.md) — how branch protection rules and pipeline gates combine to block broken merges
- [Infrastructure as Code Principles](../docs/concepts/infrastructure-as-code-principles/0000-primer-infrastructure-as-code-principles.md) — describing infrastructure in files, not by hand
- [Parameterised config generation](../docs/concepts/infrastructure-as-code-principles/parameterised-config-generation.md) — generating per-environment configs from a single source of truth with loops and conditionals
- [Scripting & Automation Philosophy](../docs/concepts/scripting-automation-philosophy/0000-primer-scripting-automation-philosophy.md) — when to reach for a script instead of doing it manually
- [Combining observability with containerization](../docs/concepts/observability-monitoring-concepts/combining-observability-with-containerization.md) — adapting logs, metrics, and traces for containerized environments
- [Observability & Monitoring Concepts](../docs/concepts/observability-monitoring-concepts/0000-primer-observability-monitoring-concepts.md) — knowing what your systems are doing in production
- [Monitoring containerized apps in production](../docs/concepts/containerization-concepts/monitoring-containerized-apps-in-production.md) — instrumenting containers with metrics, logs, and traces so they're no longer black boxes
- [Combining containerization with CI/CD: multi-stage build patterns](../docs/concepts/containerization-concepts/combining-containerization-with-ci-cd-multi-stage-build-patterns.md) — notes on combining containerization with CI/CD using multi-stage builds
- [Combining Linux CLI with networking](../docs/concepts/linux-cli-fundamentals/combining-linux-cli-with-networking-automating-network-diagnostics.md) — automating network diagnostics from the shell
- [Companion readme for version control](../docs/concepts/version-control-git-workflow/notes/2026-07-28-companion-readme.md) — companion notes on Git workflow practices

### Practice a concept hands-on
- [CI/CD stage simulation](../docs/concepts/ci-cd-pipeline-concepts/scripts/2026-07-19-pipeline-stage-sim.sh) — a pure-Bash build→test→deploy pipeline with fail-fast gating
- [Infrastructure validation gates](../docs/concepts/ci-cd-pipeline-concepts/scripts/infrastructure-validation-gates.sh) — validates Terraform and Ansible configs as a CI/CD pipeline gate
- [Artifact promotion](../docs/concepts/ci-cd-pipeline-concepts/snippets/2026-07-20-artifact-promotion.py) — promote a build artifact across pipeline stages with an audit trail
- [Pipeline metrics and health dashboards](../docs/concepts/ci-cd-pipeline-concepts/notebooks/pipeline-metrics-and-health-dashboards.ipynb) — CI/CD observability notebook with DORA metrics and pipeline health scoring
- [Container lifecycle inspection](../docs/concepts/containerization-concepts/scripts/2026-07-20-container-lifecycle-inspection.sh) — inspect running and stopped containers using the Docker API
- [Container observability: Prometheus node exporter](../docs/concepts/containerization-concepts/scripts/containerization-observability-prometheus-node-exporter.sh) — run a Prometheus node exporter container to collect host-level metrics
- [Image manifest parser](../docs/concepts/containerization-concepts/snippets/2026-07-22-image-manifest-parser.py) — parse container image manifests and extract layer metadata
- [IaC idempotency check](../docs/concepts/infrastructure-as-code-principles/scripts/2026-07-22-iac-idempotency-check.sh) — verify that a provisioning step produces the same result on repeat runs
- [Generating Docker Compose configs](../docs/concepts/infrastructure-as-code-principles/scripts/generating-docker-compose-configs.sh) — generate Docker Compose configs from IaC definitions
- [Network topology Terraform script](../docs/concepts/infrastructure-as-code-principles/scripts/network-topology-terraform.sh) — generates a Terraform config from a simple network-topology description
- [Declarative state diff](../docs/concepts/infrastructure-as-code-principles/snippets/2026-07-22-declarative-state-diff.py) — diff declarative state to detect drift
- [File permissions and processes](../docs/concepts/linux-cli-fundamentals/scripts/2026-07-24-linux-file-permissions-and-process-management.sh) — inspect and modify Linux file permissions, then list and filter running processes
- [Provision local VMs with cloud-init](../docs/concepts/linux-cli-fundamentals/scripts/provision-local-vms-with-cloud-init.sh) — boot repeatable local VMs from a cloud-init user-data file with libvirt
- [Subprocess wrapper](../docs/concepts/linux-cli-fundamentals/snippets/2026-07-24-subprocess-wrapper.py) — run a command and capture stdout/stderr/return code from Python
- [Exploring connectivity with command-line tools](../docs/concepts/linux-cli-fundamentals/notebooks/exploring-connectivity-with-command-line-tools.ipynb) — notebook exploring network connectivity and DNS resolution from the CLI
- [Network connectivity check](../docs/concepts/networking-fundamentals/scripts/2026-07-25-practice-network-connectivity-dns-port-inspection.sh) — test TCP connectivity to a host:port and diagnose why it's unreachable
- [Networking observability health check](../docs/concepts/networking-fundamentals/scripts/networking-observability-health-check.sh) — check service health and network observability
- [Network interface and routing inspection](../docs/concepts/networking-fundamentals/scripts/2026-08-05-network-interface-and-routing-inspection.sh) — inspect network interfaces and routing tables
- [Socket connection tester](../docs/concepts/networking-fundamentals/snippets/2026-07-26-socket-connection-tester.py) — Python snippet that tests TCP socket connectivity and reports the result
- [Observability exercises](../docs/concepts/observability-monitoring-concepts/scripts/2026-08-06-observability-exercises.sh) — hands-on exercises for observability concepts
- [Observability exercises — round two](../docs/concepts/observability-monitoring-concepts/scripts/2026-08-20-observability-exercises.sh) — reading a raw access log for error ratio, sampling wall-clock latency with curl, and correlating two metric streams
- [CI/CD pipeline metric collection probes](../docs/concepts/observability-monitoring-concepts/scripts/observability-cicd-pipeline-metric-collection-probes.sh) — collects CI/CD pipeline metrics and exports them to a Prometheus pushgateway endpoint
- [Applying observability in DevOps](../docs/concepts/observability-monitoring-concepts/snippets/2026-08-07-applying-observability-in-devops.py) — Python snippet that extracts RED-method golden signals from request logs

### Practice DevOps scripting and automation
- [Scripting automation exercises](../docs/concepts/scripting-automation-philosophy/scripts/2026-08-07-scripting-automation-exercises.sh) — hands-on practice for DRY helpers, idempotency, and exit codes from the scripting philosophy primer
- [Applying scripting in DevOps](../docs/concepts/scripting-automation-philosophy/snippets/2026-08-07-applying-scripting-in-devops.py) — Python snippet that parses a host inventory and applies role/env-based deploy actions
- [Deploy checklist as data](../docs/concepts/scripting-automation-philosophy/snippets/2026-08-20-scripting-deploy-checklist.py) — encodes the pre-deploy sequence as a list of steps and loops over it, so changing a check edits one entry
- [Combining scripting with CI/CD pipeline automation](../docs/concepts/scripting-automation-philosophy/combining-scripting-with-cicd-pipeline-automation.md) — notes on combining scripting with CI/CD pipeline automation
- [Terraform plan-apply idempotent](../docs/concepts/scripting-automation-philosophy/scripts/terraform-plan-apply-idempotent.sh) — idempotent Terraform plan and apply wrapper with retry logic
- [Git workflow practice exercises](../docs/concepts/version-control-git-workflow/scripts/2026-08-07-git-exercises.sh) — read-only script for inspecting repo state, branch, history, and upstream tracking
- [Applying version control in DevOps](../docs/concepts/version-control-git-workflow/snippets/2026-08-11-applying-version-control-in-devops.py) — Python snippet that parses Git commit history and correlates commits with deployment events

### Get started with GitHub Actions
- [GitHub Actions primer](../gha/notes/0000-primer-gha.md) — what GitHub Actions is, workflows vs jobs, and a minimal workflow
- [Install GitHub CLI](../gha/notes/2026-08-05-install-gh-cli.md) — check installation and configure the gh CLI
- [First workflow config](../gha/configs/2026-08-05-first-workflow.yaml) — a first GitHub Actions workflow configuration
- [Minimal CI workflow](../gha/configs/2026-08-06-minimal-ci-workflow.yaml) — a minimal GitHub Actions workflow for CI
- [GitHub Actions quickstart trip-ups](../gha/notes/2026-08-06-github-actions-quickstart-trip-ups.md) — what to expect and where beginners get stuck
- [How I learned to read workflow logs and debug failures](../gha/docs/2026-08-06-how-i-learned-to-read-workflow-logs-and-debug-failures.md) — debugging failed GitHub Actions runs

### Keep the repo's own docs in sync
- [Repo — reconcile coverage tables with on-disk counts](../repo-doc/docs/2026-08-08-reconcile-coverage-tables.md) — how I kept the README coverage table and Git index honest against what's actually on disk
