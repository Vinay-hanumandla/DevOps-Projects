# Topics

> A map of what's here. For a beginner-to-advanced reading order, see [learning-path.md](learning-path.md).

## Ansible  ·  4 files

- **primer:** [Ansible — quick primer](../ansible/notes/0000-primer-ansible.md)
- **notes** (2): [Installing Ansible and running my first command](../ansible/notes/2026-08-10-install-ansible-and-run-first-command.md)
- **configs** (2): [First ping playbook](../ansible/configs/2026-08-10-first-ping-playbook.yaml), [Install nginx playbook](../ansible/configs/2026-08-22-install-nginx-playbook.yaml)

## Bash  ·  48 files

- **primer:** [Bash — quick primer](../bash/notes/0000-primer-bash.md)
- **notes** (3): most recent → [Bash guide — trip-ups](../bash/notes/2026-07-23-bash-guide-trip-ups.md), [Install Bash and first script](../bash/notes/2026-07-18-install-bash-and-first-script.md)
- **docs** (5): most recent → [Bash 5.3 migration guide](../bash/docs/bash-5.3-migration-guide.md), [Integrating Bash with Git](../bash/docs/integrating-bash-with-git.md), [Strict mode and trap patterns](../bash/docs/strict-mode-trap-patterns.md)
- **scripts** (6): most recent → [System report tool](../bash/scripts/system-report-tool.sh), [Log rotation and retention](../bash/scripts/log-rotation-retention.sh), [Safe Bash template](../bash/scripts/2026-07-23-safe-bash-template.sh)
- **snippets** (1): [Comparing [ ] vs [[ ]] gotchas](../bash/snippets/comparing-brackets-gotchas.sh)
- **notebooks** (2): [Comparing pipeline exit-code handling](../bash/notebooks/comparing-pipeline-exit-code-handling.ipynb), [Comparing log rotation approaches](../bash/notebooks/comparing-log-rotation-approaches.ipynb)
- **dockerfiles** (1): [Strict-mode runner](../bash/dockerfiles/strict-mode-runner.Dockerfile)
- **templates** (30): [Bash + Docker scaffold](../bash/templates/bash-docker-scaffold/README.md) · [Bash + Docker health-check scaffold](../bash/templates/bash-docker-healthcheck-scaffold/README.md) · [Bash production scaffold](../bash/templates/bash-production-scaffold/README.md)
- _…and more under `bash/` — browse the folder._

## Docker  ·  12 files

- **primer:** [Docker — quick primer](../docker/notes/0000-primer-docker.md)
- **notes** (5): most recent → [Docker trip-ups after the initial run-through](../docker/notes/2026-08-06-docker-quickstart-trip-ups.md), [Install Docker](../docker/notes/2026-07-19-install-docker.md)
- **dockerfiles** (1): [Minimal non-root image](../docker/dockerfiles/2026-07-17-minimal-image-tagged-nonroot.Dockerfile)
- **scripts** (3): [Hello-world container](../docker/scripts/2026-07-19-first-hello-world.sh), [Run nginx with port map](../docker/scripts/2026-07-18-first-port-mapped-container.sh), [Run container with port map](../docker/scripts/2026-07-16-run-container-port-map.sh)
- **manifests** (1): [Multi-service Docker Compose config](../docker/manifests/2026-08-17-multi-service-docker-compose.yaml)
- **src** (2): [Sample Python HTTP server](../docker/src/2026-07-16-server.py), [Sample Go HTTP server](../docker/src/main.go)

## GitHub Actions  ·  6 files

- **primer:** [GitHub Actions — quick primer](../gha/notes/0000-primer-gha.md)
- **notes** (3): most recent → [GitHub Actions quickstart trip-ups](../gha/notes/2026-08-06-github-actions-quickstart-trip-ups.md), [Install GitHub CLI](../gha/notes/2026-08-05-install-gh-cli.md)
- **docs** (1): [How I learned to read workflow logs and debug failures](../gha/docs/2026-08-06-how-i-learned-to-read-workflow-logs-and-debug-failures.md)
- **configs** (2): [First workflow config](../gha/configs/2026-08-05-first-workflow.yaml), [Minimal CI workflow](../gha/configs/2026-08-06-minimal-ci-workflow.yaml)

## Git  ·  32 files

- **primer:** [Git — quick primer](../git/notes/0000-primer-git.md)
- **notes** (12): most recent → [Companion forgotten undo notes 15](../git/notes/2026-07-28-git-companion-forgotten-undo-notes-15.md), [Companion readme quickstart trip-ups](../git/notes/2026-07-28-git-companion-readme-quickstart-trip-ups.md), [Install Git](../git/notes/2026-07-20-install-git.md)
- **docs** (6): most recent → [Rebase vs merge at scale](../git/docs/rebase-vs-merge-at-scale.md), [Tagging Docker images from git describe](../git/docs/git-describe-image-tags-registry.md), [Git — my first file index](../git/docs/2026-08-10-git-index.md)
- **scripts** (6): most recent → [Changelog from conventional commits](../git/scripts/changelog-from-conventional-commits.sh), [Semantic release automation](../git/scripts/semantic-release-automation.sh), [Git PR helper](../git/scripts/git-pr-helper.sh)
- **hooks** (1): [Install Git hooks](../git/hooks/install.sh)
- **manifests** (1): [CI/CD pipeline trigger manifest](../git/manifests/ci-cd-pipeline-trigger.yaml) — maps git events (push, tag, merge request) to build → test → deploy jobs
- **templates** (6): [Git-based release workflow scaffold](../git/templates/release-workflow/README.md)
- _…and more under `git/` — browse the folder._

## Grafana  ·  6 files

- **primer:** [Grafana — quick primer](../grafana/notes/0000-primer-grafana.md)
- **notes** (2): [Install Grafana](../grafana/notes/2026-08-06-install-grafana.md)
- **configs** (2): [First dashboard config](../grafana/configs/2026-08-06-first-dashboard.yaml), [Datasource provisioning](../grafana/configs/2026-08-22-datasource-provisioning.yaml)
- **snippets** (2): most recent → [Create dashboard](../grafana/snippets/2026-08-22-create-dashboard.sh), [List dashboards](../grafana/snippets/2026-08-19-list-dashboards.sh)

## Helm  ·  12 files

- **primer:** [Helm — quick primer](../helm/notes/0000-primer-helm.md)
- **notes** (5): most recent → [Following the Helm quickstart](../helm/notes/2026-08-19-following-helm-quickstart.md), [Install Helm with package manager](../helm/notes/2026-08-18-install-helm-with-package-manager.md), [Explore Helm chart repo and chart structure](../helm/notes/2026-08-08-explore-helm-chart-repo.md)
- **docs** (1): [Helm — coverage check](../helm/docs/2026-08-10-helm-coverage.md)
- **configs** (4): most recent → [Dev values override](../helm/configs/2026-08-20-dev-values.yaml), [Staging values override](../helm/configs/2026-08-20-staging-values.yaml), [Prod values override](../helm/configs/2026-08-20-prod-values.yaml)
- **snippets** (1): [Deploy first chart](../helm/snippets/2026-07-31-deploy-first-chart.sh)
- **manifests** (1): [First chart template](../helm/manifests/2026-08-14-first-chart-template.yaml)

## Jenkins  ·  3 files

- **primer:** [Jenkins — quick primer](../jenkins/notes/0000-primer-jenkins.md)
- **notes** (2): [Install Jenkins and open web UI](../jenkins/notes/2026-08-11-install-jenkins-and-open-web-ui.md)
- **snippets** (1): [Hello world pipeline](../jenkins/snippets/2026-08-11-hello-world-pipeline.groovy)

## Kubernetes  ·  12 files

- **primer:** [Kubernetes — quick primer](../k8s/notes/0000-primer-kubernetes.md)
- **notes** (4): most recent → [Kubernetes quickstart tripped up](../k8s/notes/2026-08-04-kubernetes-quickstart-tripped-up.md), [Explore kubectl CLI](../k8s/notes/2026-08-03-explore-kubectl-cli.md)
- **docs** (1): [Inspecting pods, services, and events](../k8s/docs/2026-08-04-inspecting-pods-services-events.md)
- **scripts** (3): most recent → [Multi-pod deployment](../k8s/scripts/multi-pod-deployment.sh), [Install Minikube and run kubectl version](../k8s/scripts/2026-08-03-install-minikube-and-run-kubectl-version.sh)
- **configs** (1): [First deployment config](../k8s/configs/2026-08-22-first-deployment.yaml)
- **manifests** (2): [Minimal deployment and service](../k8s/manifests/2026-08-04-minimal-deployment-and-service.yaml), [Multi-service application](../k8s/manifests/multi-service-application.yaml)
- **snippets** (1): [List cluster resources](../k8s/snippets/2026-08-19-list-cluster-resources.sh)

## Prometheus  ·  5 files

- **primer:** [Prometheus — quick primer](../prom/notes/0000-primer-prometheus.md)
- **notes** (2): [Install and explore web UI](../prom/notes/2026-08-07-install-and-explore-web-ui.md)
- **configs** (2): [First scrape target](../prom/configs/2026-08-07-first-scrape-target.yaml), [Scrape config](../prom/configs/2026-08-22-prometheus-scrape-config.yaml)
- **snippets** (1): [First PromQL query](../prom/snippets/2026-08-19-first-promql-query.sh)

## Python  ·  13 files

- **primer:** [Python — quick primer](../python/notes/0000-primer-python.md)
- **notes** (3): most recent → [Python quickstart gotchas](../python/notes/2026-08-22-python-quickstart-gotchas.md), [Python functions and modules](../python/notes/2026-08-04-python-functions-modules.md)
- **docs** (2): most recent → [Comparing Python configuration approaches for DevOps workflows](../python/docs/comparing-python-configuration-approaches.md), [Python modules, packages, and imports](../python/docs/2026-08-04-python-modules-packages-imports.md)
- **scripts** (3): most recent → [Config validator](../python/scripts/config-validator.py), [Minimal file processing](../python/scripts/2026-08-04-minimal-file-processing.py), [Create venv and run](../python/scripts/2026-07-22-create-venv-and-run.py)
- **snippets** (4): most recent → [Dockerfile validator](../python/snippets/validate-dockerfile.py), [Docker Compose validator](../python/snippets/docker-compose-validator.py), [Config file reader](../python/snippets/2026-08-22-config-file-reader.py), [First script — variables and types](../python/snippets/2026-07-22-first-script-variables-types.py)
- **configs** (1): [First pyproject.toml](../python/configs/2026-08-24-pyproject-toml-config.toml)

## Terraform  ·  9 files

- **primer:** [Terraform — quick primer](../tf/notes/0000-primer-terraform.md)
- **notes** (3): most recent → [Quickstart trip-ups](../tf/notes/2026-08-08-quickstart-trip-ups.md), [Install Terraform and run first version command](../tf/notes/2026-07-26-install-terraform-and-run-first-version-command.md)
- **configs** (3): most recent → [Minimal provider resource](../tf/configs/2026-08-08-minimal-provider-resource.hcl), [First Terraform provider resource](../tf/configs/2026-08-06-first-terraform-provider-resource.hcl)
- **docs** (2): most recent → [Terraform — coverage check](../tf/docs/2026-08-11-terraform-coverage.md), [Terraform project structure](../tf/docs/2026-08-06-terraform-project-structure.md)
- **scripts** (1): [Terraform init, plan, apply](../tf/scripts/2026-08-08-tf-init-plan-apply.sh)

## Repo-doc  ·  1 file

- **docs** (1): [Repo — reconcile coverage tables with on-disk counts](../repo-doc/docs/2026-08-08-reconcile-coverage-tables.md)

## Concepts (docs/concepts/)  ·  61 files

Foundational primers on the ideas the tools build on — one primer per concept, plus runnable scripts, snippets, and notebooks. Each folder holds more than the highlights below.

- **CI/CD Pipeline Concepts** (10): [primer](../docs/concepts/ci-cd-pipeline-concepts/0000-primer-ci-cd-pipeline-concepts.md) · [gate-before-merge with branch protection](../docs/concepts/ci-cd-pipeline-concepts/gate-before-merge-branch-protection.md) · [infrastructure validation gates](../docs/concepts/ci-cd-pipeline-concepts/scripts/infrastructure-validation-gates.sh) · notebook: [Pipeline metrics and health dashboards](../docs/concepts/ci-cd-pipeline-concepts/notebooks/pipeline-metrics-and-health-dashboards.ipynb) · _…and 6 more under `docs/concepts/ci-cd-pipeline-concepts/`._
- **Containerization Concepts** (6): [primer](../docs/concepts/containerization-concepts/0000-primer-containerization-concepts.md) · [monitoring containerized apps in production](../docs/concepts/containerization-concepts/monitoring-containerized-apps-in-production.md) · script: [Container observability with the Prometheus node exporter](../docs/concepts/containerization-concepts/scripts/containerization-observability-prometheus-node-exporter.sh) · _…and 3 more under `docs/concepts/containerization-concepts/`._
- **Infrastructure as Code Principles** (7): [primer](../docs/concepts/infrastructure-as-code-principles/0000-primer-infrastructure-as-code-principles.md) · [parameterised config generation](../docs/concepts/infrastructure-as-code-principles/parameterised-config-generation.md) · [state file management strategies](../docs/concepts/infrastructure-as-code-principles/state-file-management-strategies.md) · script: [Network topology Terraform generator](../docs/concepts/infrastructure-as-code-principles/scripts/network-topology-terraform.sh) · _…and 3 more under `docs/concepts/infrastructure-as-code-principles/`._
- **Linux & CLI Fundamentals** (8): [primer](../docs/concepts/linux-cli-fundamentals/0000-primer-linux-cli-fundamentals.md) · [automating network diagnostics from the shell](../docs/concepts/linux-cli-fundamentals/combining-linux-cli-with-networking-automating-network-diagnostics.md) · script: [Provision local VMs with cloud-init](../docs/concepts/linux-cli-fundamentals/scripts/provision-local-vms-with-cloud-init.sh) · notebook: [Exploring connectivity with command-line tools](../docs/concepts/linux-cli-fundamentals/notebooks/exploring-connectivity-with-command-line-tools.ipynb) · _…and 4 more under `docs/concepts/linux-cli-fundamentals/`._
- **Networking Fundamentals** (11): [primer](../docs/concepts/networking-fundamentals/0000-primer-networking-fundamentals.md) · [combining networking with containerization](../docs/concepts/networking-fundamentals/combining-networking-with-containerization.md) · notebook: [Overlay networks and service mesh exploration](../docs/concepts/networking-fundamentals/notebooks/overlay-networks-and-service-mesh-exploration.ipynb) · snippet: [Applying networking in DevOps](../docs/concepts/networking-fundamentals/snippets/2026-08-23-applying-networking-in-devops.py) · script: [Path MTU discovery](../docs/concepts/networking-fundamentals/scripts/2026-08-24-path-mtu-discovery.sh) · _…and 5 more under `docs/concepts/networking-fundamentals/`._
- **Observability & Monitoring Concepts** (6): [primer](../docs/concepts/observability-monitoring-concepts/0000-primer-observability-monitoring-concepts.md) · script: [Observability exercises — round two](../docs/concepts/observability-monitoring-concepts/scripts/2026-08-20-observability-exercises.sh) · script: [CI/CD pipeline metric collection probes](../docs/concepts/observability-monitoring-concepts/scripts/observability-cicd-pipeline-metric-collection-probes.sh) · snippet: [Applying observability in DevOps](../docs/concepts/observability-monitoring-concepts/snippets/2026-08-07-applying-observability-in-devops.py) · _…and 2 more under `docs/concepts/observability-monitoring-concepts/`._
- **Scripting & Automation Philosophy** (6): [primer](../docs/concepts/scripting-automation-philosophy/0000-primer-scripting-automation-philosophy.md) · snippet: [Deploy checklist as data](../docs/concepts/scripting-automation-philosophy/snippets/2026-08-20-scripting-deploy-checklist.py) · script: [Terraform plan/apply, made idempotent](../docs/concepts/scripting-automation-philosophy/scripts/terraform-plan-apply-idempotent.sh) · _…and 3 more under `docs/concepts/scripting-automation-philosophy/`._
- **Version Control & Git Workflow** (7): [primer](../docs/concepts/version-control-git-workflow/0000-primer-version-control-git-workflow.md) · [branch strategy and pipeline triggers](../docs/concepts/version-control-git-workflow/branch-strategy-and-pipeline-triggers.md) · snippet: [Release-readiness commit inventory](../docs/concepts/version-control-git-workflow/snippets/2026-08-20-release-branch-commit-check.py) · snippet: [Correlating commit history with deployments](../docs/concepts/version-control-git-workflow/snippets/analyzing-git-commit-history-for-deployment-correlation.py) · _…and 3 more under `docs/concepts/version-control-git-workflow/`._
