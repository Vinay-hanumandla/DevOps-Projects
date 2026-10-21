# Quick Links

## I need to...

### Set up a Git repository
- [Git primer](../git/notes/0000-primer-git.md) — Repos, branches, staging, and workflows.
- [Install Git and first repo](../git/notes/2026-07-20-install-git.md) — Step-by-step first repository setup.
- [First-repo lifecycle script](../git/scripts/2026-07-20-first-repo.sh) — Runnable script that initialises, commits, and tags a new repo.
- [Git hooks install script](../git/hooks/install.sh) — Installs pre-commit and pre-push hooks for linting and tests.
- [Branch-merge-revert practice script](../git/scripts/2026-07-20-branch-merge-revert.sh) — Hands-on exercise for branch workflows.

### Write robust Bash scripts
- [Bash primer](../bash/notes/0000-primer-bash.md) — Shell fundamentals, strict mode, and best practices.
- [Install Bash and first script](../bash/notes/2026-07-18-install-bash-and-first-script.md) — First script with shebang, variables, and execution.
- [Safe Bash template](../bash/scripts/2026-07-23-safe-bash-template.sh) — Boilerplate with strict mode, traps, and logging.
- [Strict mode and trap patterns](../bash/docs/strict-mode-trap-patterns.md) — Deep dive on `set -Eeuo pipefail` and signal handling.
- [Bash production runbook](../bash/docs/bash-production-runbook.md) — Strict mode, once-only trap cleanup, and correlation-ID logging.
- [System report tool](../bash/scripts/system-report-tool.sh) — Example of a production-grade info-gathering script.

### Build and run Docker containers
- [Docker primer](../docker/notes/0000-primer-docker.md) — Images, containers, registries, and workflows.
- [Docker quickstart trip-ups](../docker/notes/2026-07-13-docker-quickstart-trip-ups.md) — Common first-contact pitfalls.
- [Minimal non-root Dockerfile](../docker/dockerfiles/2026-07-17-minimal-image-tagged-nonroot.Dockerfile) — Secure, tagged, non-root starting point.
- [Multi-stage non-root image](../docker/dockerfiles/multi-stage-nonroot.Dockerfile) — Build stage separation for smaller final images.
- [Run first port-mapped container](../docker/scripts/2026-07-18-first-port-mapped-container.sh) — Runnable example with port mapping.

### Orchestrate with Docker Compose
- [Compose primer](../compose/notes/0000-primer-compose.md) — Services, networks, volumes, and the up/down loop.
- [First compose up notes](../compose/notes/2026-10-14-first-compose-up.md) — Port-order and hostname gotchas.
- [Compose `depends_on` + healthchecks](../compose/notes/2026-10-21-depends-on-healthchecks.md) — Why `depends_on` alone does not wait for a database to be ready.
- [Minimal multi-service Compose stack](../compose/configs/2026-10-21-minimal-multi-service-stack.yaml) — Web, db, and cache with `condition: service_healthy` startup ordering.
- [Compose lifecycle script](../compose/scripts/2026-10-21-compose-lifecycle.sh) — Up, wait-for-healthy, logs, and tear-down.

### Work with Kubernetes
- [Kubernetes primer](../k8s/notes/0000-primer-kubernetes.md) — Core objects, namespaces, pods, and kubectl usage.
- [Install Minikube and kubectl](../k8s/scripts/2026-08-03-install-minikube-and-run-kubectl-version.sh) — Local cluster setup script.
- [Kubectl exploration notes](../k8s/notes/2026-08-03-explore-kubectl-cli.md) — First commands for cluster inspection.
- [Minimal deployment and service](../k8s/manifests/2026-08-04-minimal-deployment-and-service.yaml) — Starting manifest for a workload.
- [Multi-service application manifest](../k8s/manifests/multi-service-application.yaml) — Web frontend, API backend, Redis with Deployments and Services.

### Package Kubernetes apps with Helm
- [Helm primer](../helm/notes/0000-primer-helm.md) — Charts, releases, values, and templates.
- [Install Helm and version check](../helm/notes/2026-07-31-install-helm-run-version.md) — Installation and verification.
- [First chart deployment snippet](../helm/snippets/2026-07-31-deploy-first-chart.sh) — One-liner to install a chart.
- [Dev/staging/prod values overrides](../helm/configs/2026-08-20-dev-values.yaml) — Environment-specific configuration.

### Explore public Helm Charts
- [Helm Charts primer](../hchart/notes/0000-primer-hchart.md) — Working with community charts.
- [Public chart structure teardown](../hchart/notes/2026-10-14-explore-public-chart-structure.md) — Reading a real chart layout.
- [Minimal Chart.yaml/values.yaml](../hchart/configs/2026-10-14-minimal-chart.yaml) — Smallest chart scaffolding.

### Provision infrastructure with Terraform
- [Terraform primer](../tf/notes/0000-primer-terraform.md) — IaC fundamentals, state, providers, and workflows.
- [Install Terraform and first version](../tf/notes/2026-07-26-install-terraform-and-run-first-version-command.md) — Setup and first command.
- [First local file resource](../tf/configs/2026-07-26-first-terraform-local-file-resource.hcl) — Minimal config creating a local file.
- [Terraform init/validate/plan/apply with lock handling](../tf/scripts/2026-09-04-tf-init-validate-plan-apply-with-lock-handling.sh) — CI-ready workflow wrapper.
- [Reusable VPC module](../tf/configs/reusable-vpc-module.hcl) — Copy-in module for VPC with public/private subnets, NAT, route tables.

### Use Terraform Cloud
- [Terraform Cloud primer](../tfc/notes/0000-primer-tfc.md) — Workspaces, runs, and remote state.
- [Explore workspaces](../tfc/notes/2026-10-14-explore-workspaces.md) — Navigating runs, states, and variables.
- [Minimal cloud backend](../tfc/configs/2026-10-14-minimal-cloud-backend.hcl) — Pointing to a TFC workspace.

### Automate with Ansible
- [Ansible primer](../ansible/notes/0000-primer-ansible.md) — Core concepts, architecture, and workflow essentials.
- [Install Ansible and first command](../ansible/notes/2026-08-10-install-ansible-and-run-first-command.md) — Installation via pipx and first ad-hoc command.
- [First ping playbook](../ansible/configs/2026-08-10-first-ping-playbook.yaml) — Minimal playbook to validate connectivity.
- [Idempotent Nginx playbook](../ansible/configs/2026-08-31-idempotent-nginx-playbook.yaml) — Real-world playbook with handlers and idempotent modules.
- [Ansible ad-hoc toolkit](../ansible/scripts/2026-08-31-ansible-adhoc-toolkit.sh) — Reusable ad-hoc commands for common tasks.

### Manage with AWX
- [AWX primer](../awx/notes/0000-primer-awx.md) — Jobs, templates, inventories, and credentials.
- [Explore AWX UI and API](../awx/notes/2026-10-04-explore-awx-ui-and-api.md) — Walking the API behind the UI.
- [First job template run](../awx/notes/2026-10-07-explore-awx-ui-first-job-template.md) — From CR to launched job.
- [AWX quickstart script](../awx/scripts/2026-10-20-awx-quickstart.sh) — Deploy the AWX operator and run a first job template.

### Run CI/CD with GitHub Actions
- [GitHub Actions primer](../gha/notes/0000-primer-gha.md) — Workflows, jobs, steps, and triggers.
- [Install gh CLI](../gha/notes/2026-08-05-install-gh-cli.md) — GitHub CLI setup for local workflow runs.
- [Minimal CI workflow](../gha/configs/2026-08-06-minimal-ci-workflow.yaml) — Lint, test, and build on push.
- [Matrix + cache + artifact CI](../gha/configs/matrix-cache-artifact-ci.yaml) — Multi-OS matrix with dependency caching.
- [Production CI template](../gha/templates/production-ci-template/ci.yml) — Full-featured CI with reusable actions.

### Run CI/CD with Jenkins
- [Jenkins primer](../jenkins/notes/0000-primer-jenkins.md) — Jobs, nodes, pipelines, and plugins.
- [Install Jenkins and open web UI](../jenkins/notes/2026-08-11-install-jenkins-and-open-web-ui.md) — Controller setup and first login.
- [Minimal declarative Jenkinsfile](../jenkins/configs/2026-09-05-minimal-declarative-jenkinsfile.jenkinsfile) — Starter pipeline with Build, Test, post-blocks.
- [Hello-world pipeline snippet](../jenkins/snippets/2026-08-11-hello-world-pipeline.groovy) — Minimal job to paste and run.
- [Environment-credentials pipeline](../jenkins/snippets/2026-09-05-environment-credentials-pipeline.groovy) — Binding secrets with `withCredentials`.

### Monitor with Prometheus and Grafana
- [Prometheus primer](../prom/notes/0000-primer-prometheus.md) — PromQL basics, scrape configs, and alerting.
- [Install and explore web UI](../prom/notes/2026-08-07-install-and-explore-web-ui.md) — First contact with Prometheus UI.
- [First scrape target config](../prom/configs/2026-08-07-first-scrape-target.yaml) — Minimal `prometheus.yml` for a single target.
- [Grafana primer](../grafana/notes/0000-primer-grafana.md) — Dashboards, provisioning, and alerting.
- [Install Grafana](../grafana/notes/2026-08-06-install-grafana.md) — Setup and first login.
- [First dashboard config](../grafana/configs/2026-08-06-first-dashboard.yaml) — Provisioned dashboard as code.

### Use Kube-Prometheus stack on Kubernetes
- [Kube-Prometheus primer](../kprom/notes/0000-primer-kube-prometheus.md) — kube-prometheus-stack overview.
- [Install and explore Grafana](../kprom/notes/2026-10-08-install-kube-prometheus-stack-and-explore-grafana.md) — First cluster install.
- [Quickstart walkthrough](../kprom/notes/2026-10-10-quickstart-walkthrough-kube-prometheus-stack.md) — ServiceMonitor/PodMonitor and gotchas.
- [Minimal local values](../kprom/configs/2026-10-08-minimal-kube-prometheus-local-values.yaml) — NodePort exposure for laptop use.
- [ServiceMonitor + PrometheusRule](../kprom/manifests/2026-10-12-servicemonitor-prometheusrule-red-metrics.yaml) — First scrape and alerts.
