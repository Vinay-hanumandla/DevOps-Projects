# Topics

> A map of what's here. For a beginner-to-advanced reading order, see [learning-path.md](learning-path.md).

## Ansible  ·  31 files

- **primer:** [Ansible — quick primer](../ansible/notes/0000-primer-ansible.md)
- **notes** (3): most recent → [Ansible quickstart gotchas](../ansible/notes/2026-08-31-ansible-quickstart-gotchas.md), [Installing Ansible and running my first command](../ansible/notes/2026-08-10-install-ansible-and-run-first-command.md)
- **docs** (3): most recent → [command/shell vs purpose-built idempotent modules](../ansible/docs/command-shell-vs-idempotent-modules.md), [Managing Kubernetes with Ansible](../ansible/docs/managing-kubernetes-with-ansible.md), [Wired handlers and idempotency for a fleet](../ansible/docs/wired-handlers-idempotency-fleet.md)
- **configs** (4): most recent → [VPS hardening playbook](../ansible/configs/vps-hardening-playbook.yaml), [Idempotent nginx playbook](../ansible/configs/2026-08-31-idempotent-nginx-playbook.yaml), [Install nginx playbook](../ansible/configs/2026-08-22-install-nginx-playbook.yaml)
- **scripts** (3): most recent → [Gated playbook run](../ansible/scripts/ansible-playbook-gated-run.sh), [Ansible ad-hoc toolkit](../ansible/scripts/2026-08-31-ansible-adhoc-toolkit.sh), [Ansible playbook wrapper](../ansible/scripts/ansible-playbook-wrapper.sh)
- **manifests** (1): [Terraform dynamic inventory](../ansible/manifests/terraform-dynamic-inventory.yaml) — builds the inventory from Terraform workspace outputs via the `tfc_inv` plugin
- **snippets** (1): [Block/rescue/always deploy with handlers](../ansible/snippets/block-rescue-always-handlers.yaml) — config deploy with rollback, outcome report, and a change-gated service restart
- **templates** (16): [Role scaffold with Molecule and collection layout](../ansible/templates/ansible-role-molecule-collection/README.md) — copy-in role with Molecule tests, `galaxy.yml`, dynamic cloud inventory, and a Terraform-outputs handoff script · _…and 15 more under `ansible/templates/ansible-role-molecule-collection/`._

## Bash  ·  54 files

- **primer:** [Bash — quick primer](../bash/notes/0000-primer-bash.md)
- **notes** (3): most recent → [Bash guide — trip-ups](../bash/notes/2026-07-23-bash-guide-trip-ups.md), [Install Bash and first script](../bash/notes/2026-07-18-install-bash-and-first-script.md)
- **docs** (6): most recent → [Bash 5.3 deep dive](../bash/docs/bash-5.3-deep-dive.md), [Strict mode and trap patterns](../bash/docs/strict-mode-trap-patterns.md), [Debug and profile with set -x and trace traps](../bash/docs/debug-and-profile-with-set-x-and-trace-traps.md)
- **scripts** (9): most recent → [Companion test for the first script](../bash/scripts/2026-09-05-companion-test.sh), [CI-safe build wrapper](../bash/scripts/build-and-check.sh), [System report tool](../bash/scripts/system-report-tool.sh)
- **snippets** (1): [Comparing [ ] vs [[ ]] gotchas](../bash/snippets/comparing-brackets-gotchas.sh)
- **notebooks** (4): most recent → [Bats-core production test suite](../bash/notebooks/bats-core-production-test-suite.ipynb), [Comparing shellcheck profiles](../bash/notebooks/comparing-shellcheck-profiles.ipynb), [Comparing pipeline exit-code handling](../bash/notebooks/comparing-pipeline-exit-code-handling.ipynb)
- **dockerfiles** (1): [Strict-mode runner](../bash/dockerfiles/strict-mode-runner.Dockerfile)
- **templates** (30): [Bash + Docker scaffold](../bash/templates/bash-docker-scaffold/README.md) · [Bash + Docker health-check scaffold](../bash/templates/bash-docker-healthcheck-scaffold/README.md) · [Bash production scaffold](../bash/templates/bash-production-scaffold/README.md)
- _…and more under `bash/` — browse the folder._

## Docker  ·  42 files

- **primer:** [Docker — quick primer](../docker/notes/0000-primer-docker.md)
- **notes** (5): most recent → [Docker trip-ups after the initial run-through](../docker/notes/2026-08-06-docker-quickstart-trip-ups.md), [Install Docker](../docker/notes/2026-07-19-install-docker.md)
- **dockerfiles** (4): most recent → [Production-hardened Python web service](../docker/dockerfiles/production-hardened-python-web-service.Dockerfile), [Production distroless image with SBOM](../docker/dockerfiles/production-distroless-sbom.Dockerfile), [Multi-stage non-root image](../docker/dockerfiles/multi-stage-nonroot.Dockerfile)
- **docs** (3): most recent → [Multi-stage build patterns for Python services](../docker/docs/multi-stage-build-patterns-python-services.md), [Storage drivers and volume types for stateful workloads](../docker/docs/storage-drivers-volume-types-comparison.md), [Docker Compose healthcheck service ordering](../docker/docs/docker-compose-healthcheck-service-ordering.md)
- **scripts** (7): most recent → [Image vuln scan and policy enforcement](../docker/scripts/image-vuln-scan-policy.sh), [Multi-arch buildx automation](../docker/scripts/image-build-automation.sh), [Build containerized app with custom networks and volumes](../docker/scripts/build-containerized-app-custom-networks-volumes.sh)
- **manifests** (2): most recent → [GitOps image build, sign, and push](../docker/manifests/gitops-image-build-and-push.yaml), [Multi-service Docker Compose config](../docker/manifests/2026-08-17-multi-service-docker-compose.yaml)
- **templates** (18): [Multi-service Compose app scaffold](../docker/templates/multi-service-compose-app/README.md) — copy-in stack with health-gated startup, file-based secrets, and a tools profile · [Local dev cluster scaffold](../docker/templates/local-dev-cluster/README.md) — kind config, Compose file, and k8s manifests for a throwaway dev loop · _…and 16 more under `docker/templates/`._
- **src** (2): [Sample Python HTTP server](../docker/src/2026-07-16-server.py), [Sample Go HTTP server](../docker/src/main.go)

## GitHub Actions  ·  16 files

- **primer:** [GitHub Actions — quick primer](../gha/notes/0000-primer-gha.md)
- **notes** (3): most recent → [GitHub Actions quickstart trip-ups](../gha/notes/2026-08-06-github-actions-quickstart-trip-ups.md), [Install GitHub CLI](../gha/notes/2026-08-05-install-gh-cli.md)
- **docs** (3): most recent → [Tag-triggered release workflows](../gha/docs/tag-triggered-release-workflows.md), [GitHub Actions quickstart gotchas](../gha/docs/2026-08-27-quickstart-gotchas.md), [How I learned to read workflow logs and debug failures](../gha/docs/2026-08-06-how-i-learned-to-read-workflow-logs-and-debug-failures.md)
- **configs** (6): most recent → [Reusable composite action caller](../gha/configs/reusable-composite-action-caller.yaml), [Reusable composite action](../gha/configs/reusable-composite-action/action.yml) · _…and 4 more under `gha/configs/`._
- **scripts** (2): [Minimal custom JavaScript action](../gha/scripts/action.yml) — action definition on the node20 runtime; [Minimal custom JavaScript action entrypoint](../gha/scripts/minimal-custom-js-action.js) — reads two inputs, composes a greeting, and exposes it via `$GITHUB_OUTPUT`
- **notebooks** (1): [Matrix vs single-job CI strategies](../gha/notebooks/comparing-matrix-vs-single-job-ci-strategies.ipynb)
- **snippets** (1): [Reusable workflow caller](../gha/snippets/reusable-workflow-caller.yaml) — minimal caller of a centrally maintained reusable workflow, passing inputs and secrets and reading outputs downstream

## Git  ·  49 files

- **primer:** [Git — quick primer](../git/notes/0000-primer-git.md)
- **notes** (16): most recent → [Companion forgotten undo notes](../git/notes/2026-08-25-forgotten.md), [Git companion file quickstart](../git/notes/2026-09-10-git-companion-file-quickstart.txt), [Git companion readme primer](../git/notes/2026-09-10-git-companion-readme-primer.txt), [Git companion readme quickstart](../git/notes/2026-09-10-git-companion-readme-quickstart.md)
- **docs** (10): most recent → [Worktree workflows for parallel feature development](../git/docs/worktree-parallel-feature-development.md), [Choosing between submodules, subtrees, and monorepo](../git/docs/2026-09-08-choosing-submodules-subtrees-monorepo.md), [Rebase vs merge at scale](../git/docs/rebase-vs-merge-at-scale.md)
- **scripts** (6): most recent → [Changelog from conventional commits](../git/scripts/changelog-from-conventional-commits.sh), [Semantic release automation](../git/scripts/semantic-release-automation.sh), [Git PR helper](../git/scripts/git-pr-helper.sh)
- **hooks** (1): [Install Git hooks](../git/hooks/install.sh)
- **manifests** (1): [CI/CD pipeline trigger manifest](../git/manifests/ci-cd-pipeline-trigger.yaml) — maps git events (push, tag, merge request) to build → test → deploy jobs
- **templates** (15): [Git-based release workflow scaffold](../git/templates/release-workflow/README.md) · [Repo scaffold with hooks and branch protection](../git/templates/repo-scaffold/README.md)
- _…and more under `git/` — browse the folder._

## Grafana  ·  17 files

- **primer:** [Grafana — quick primer](../grafana/notes/0000-primer-grafana.md)
- **notes** (4): most recent → [First Grafana web UI](../grafana/notes/2026-08-27-first-grafana-web-ui.md), [Grafana quickstart gotchas](../grafana/notes/2026-08-27-grafana-quickstart-gotchas.md), [Install Grafana](../grafana/notes/2026-08-06-install-grafana.md)
- **configs** (6): most recent → [Provisioned dashboard with panels and variables](../grafana/configs/provisioned-dashboard-panels-variables.yaml), [Loki datasource provisioning](../grafana/configs/2026-08-30-loki-datasource-provisioning.yaml), [Grafana datasource provisioning](../grafana/configs/2026-08-29-grafana-datasource-provisioning.yaml)
- **docs** (1): [Prometheus + Alertmanager on-call pipeline](../grafana/docs/prometheus-alertmanager-oncall-pipeline.md)
- **manifests** (1): [Production provisioning bundle](../grafana/manifests/production-provisioning-datasources-dashboards-alerts.yaml)
- **scripts** (1): [Grafana dashboard API wrapper](../grafana/scripts/grafana-http-api-dashboard-wrapper.sh) — list, idempotent create/update, and safe delete via the HTTP API
- **snippets** (3): most recent → [List dashboards and datasources](../grafana/snippets/2026-09-09-list-dashboards-datasources.py), [Create dashboard](../grafana/snippets/2026-08-22-create-dashboard.sh), [List dashboards](../grafana/snippets/2026-08-19-list-dashboards.sh)
- **notebooks** (1): [Comparing Grafana unified alerting vs Alertmanager](../grafana/notebooks/comparing-grafana-unified-alerting-vs-alertmanager.ipynb)

## Helm  ·  18 files

- **primer:** [Helm — quick primer](../helm/notes/0000-primer-helm.md)
- **notes** (5): most recent → [Following the Helm quickstart](../helm/notes/2026-08-19-following-helm-quickstart.md), [Install Helm with package manager](../helm/notes/2026-08-18-install-helm-with-package-manager.md), [Explore Helm chart repo and chart structure](../helm/notes/2026-08-08-explore-helm-chart-repo.md)
- **docs** (2): most recent → [Helm values inheritance and environment overrides](../helm/docs/helm-values-inheritance.md), [Helm — coverage check](../helm/docs/2026-08-10-helm-coverage.md)
- **configs** (6): most recent → [Chart.yaml scaffold](../helm/configs/chart-scaffold.yaml), [Multi-environment Helm values](../helm/configs/multi-environment-helm-values.yaml), [Dev values override](../helm/configs/2026-08-20-dev-values.yaml), [Staging values override](../helm/configs/2026-08-20-staging-values.yaml), [Prod values override](../helm/configs/2026-08-20-prod-values.yaml)
- **snippets** (1): [Deploy first chart](../helm/snippets/2026-07-31-deploy-first-chart.sh)
- **manifests** (2): most recent → [Hooks lifecycle manifest](../helm/manifests/hooks-lifecycle.yaml), [First chart template](../helm/manifests/2026-08-14-first-chart-template.yaml)
- **scripts** (1): [Helm release workflow](../helm/scripts/helm-release-workflow.sh)
- **notebooks** (1): [Comparing Helm values merging](../helm/notebooks/comparing-helm-values-merging.ipynb)

## Jenkins  ·  10 files

- **primer:** [Jenkins — quick primer](../jenkins/notes/0000-primer-jenkins.md)
- **notes** (4): most recent → [Following the official Jenkins tutorial](../jenkins/notes/2026-09-06-followed-jenkins-tutorial.md), [Jenkins quickstart follow-up](../jenkins/notes/2026-09-03-quickstart-follow-up.md), [Install Jenkins and open web UI](../jenkins/notes/2026-08-11-install-jenkins-and-open-web-ui.md)
- **configs** (1): [Minimal declarative Jenkinsfile](../jenkins/configs/2026-09-05-minimal-declarative-jenkinsfile.jenkinsfile)
- **docs** (2): [Moving a Jenkinsfile from inline script to SCM](../jenkins/docs/2026-09-19-moving-jenkinsfile-to-scm-gotchas.md), [What tripped me up following the Jenkins declarative pipeline tutorial](../jenkins/docs/2026-09-19-what-tripped-me-following-jenkins-declarative-pipeline-tutorial.md) — Script Path, branch specifier, lightweight checkout, and credential-ID gotchas
- **snippets** (3): most recent → [Shared-library + credentials pipeline](../jenkins/snippets/2026-09-19-shared-library-credentials.groovy), [Environment-credentials pipeline](../jenkins/snippets/2026-09-05-environment-credentials-pipeline.groovy), [Hello world pipeline](../jenkins/snippets/2026-08-11-hello-world-pipeline.groovy)

## Kubernetes  ·  31 files

- **primer:** [Kubernetes — quick primer](../k8s/notes/0000-primer-kubernetes.md)
- **notes** (5): most recent → [Kubernetes quickstart tripped up](../k8s/notes/2026-08-04-kubernetes-quickstart-tripped-up.md), [Quickstart kind contexts and port mismatch](../k8s/notes/2026-09-16-quickstart-kind-contexts-and-port-mismatch.md), [Explore kubectl CLI](../k8s/notes/2026-08-03-explore-kubectl-cli.md)
- **docs** (4): [Kubernetes with Helm, ArgoCD, and GitOps](../k8s/docs/kubernetes-helm-argocd-gitops-workflow.md) — end-to-end GitOps workflow using Helm chart packaging, ArgoCD sync, and sealed-secrets for continuous delivery, [Inspecting pods, services, and events](../k8s/docs/2026-08-04-inspecting-pods-services-events.md), [kubectl imperative vs declarative](../k8s/docs/kubectl-imperative-vs-declarative.md), [Integrating Kubernetes with Terraform](../k8s/docs/integrating-kubernetes-with-terraform.md)
- **scripts** (3): most recent → [Multi-pod deployment](../k8s/scripts/multi-pod-deployment.sh), [Install Minikube and run kubectl version](../k8s/scripts/2026-08-03-install-minikube-and-run-kubectl-version.sh)
- **configs** (1): [First deployment config](../k8s/configs/2026-08-22-first-deployment.yaml)
- **manifests** (4): most recent → [Production-ready deployment](../k8s/manifests/production-deployment.yaml), [Zero-downtime rolling deployment](../k8s/manifests/zero-downtime-rolling-deployment.yaml), [Multi-service application](../k8s/manifests/multi-service-application.yaml), [Minimal deployment and service](../k8s/manifests/2026-08-04-minimal-deployment-and-service.yaml)
- **snippets** (2): [List cluster resources](../k8s/snippets/2026-08-19-list-cluster-resources.sh), [Pod metrics via the API](../k8s/snippets/kubectl-pod-metrics.py)
- **notebooks** (1): [Comparing Kubernetes rollout strategies](../k8s/notebooks/comparing-kubernetes-rollout-strategies.ipynb)
- **dockerfiles** (1): [Operator development image](../k8s/dockerfiles/operator-dev.Dockerfile)
- **templates** (10): [Multi-service app Helm-chart scaffold](../k8s/templates/multi-service-app/README.md) — two-tier frontend/backend chart with ingress routing and Prometheus alert rules · _…and 9 more under `k8s/templates/multi-service-app/`._

## Prometheus  ·  15 files

- **primer:** [Prometheus — quick primer](../prom/notes/0000-primer-prometheus.md)
- **notes** (4): most recent → [Prometheus quickstart trip-ups](../prom/notes/2026-08-30-prometheus-quickstart-trip-ups.md), [Install Prometheus and explore web UI](../prom/notes/2026-08-29-install-prometheus-explore-web-ui.md), [Install and explore web UI](../prom/notes/2026-08-07-install-and-explore-web-ui.md)
- **docs** (2): [PromQL rate increase, histogram, and quantile](../prom/docs/2026-09-19-promql-rate-increase-histogram-quantile.md) — detecting sudden error-rate increases with `rate()`, bucket histograms, and `quantile_over_time()` for SLO burn-rate alerts, [Hybrid service discovery](../prom/docs/hybrid-service-discovery.md) — combining file-based, DNS, and Consul service discovery with priority fallbacks
- **configs** (6): most recent → [Kubernetes pod service discovery](../prom/configs/2026-09-18-kubernetes-service-discovery.yaml), [Remote-write vs federation](../prom/configs/remote-write-vs-federation.yaml), [Prometheus alerting rules](../prom/configs/2026-08-30-prometheus-alerting-rules.yaml) · _…and 3 more under `prom/configs/`._
- **scripts** (2): [Rules evaluator](../prom/scripts/rules-evaluator.go) — evaluates Prometheus recording and alerting rules against fetched metrics · [Prom query helper](../prom/scripts/2026-09-03-prom-query-helper.sh)
- **snippets** (1): [First PromQL query](../prom/snippets/2026-08-19-first-promql-query.sh)

## Python  ·  29 files

- **primer:** [Python — quick primer](../python/notes/0000-primer-python.md)
- **notes** (3): most recent → [Python quickstart gotchas](../python/notes/2026-08-22-python-quickstart-gotchas.md), [Python functions and modules](../python/notes/2026-08-04-python-functions-modules.md)
- **docs** (3): most recent → [Comparing Python configuration approaches for DevOps workflows](../python/docs/comparing-python-configuration-approaches.md), [Python modules, packages, and imports](../python/docs/2026-08-04-python-modules-packages-imports.md)
- **scripts** (4): most recent → [Config loader with Pydantic settings](../python/scripts/config-loader-pydantic-settings.py), [Config validator](../python/scripts/config-validator.py), [Minimal file processing](../python/scripts/2026-08-04-minimal-file-processing.py), [Create venv and run](../python/scripts/2026-07-22-create-venv-and-run.py)
- **snippets** (4): most recent → [Dockerfile validator](../python/snippets/validate-dockerfile.py), [Docker Compose validator](../python/snippets/docker-compose-validator.py), [Config file reader](../python/snippets/2026-08-22-config-file-reader.py), [First script — variables and types](../python/snippets/2026-07-22-first-script-variables-types.py)
- **configs** (4): most recent → [App config for the Pydantic loader](../python/configs/2026-09-16-app-config.yaml), [pyproject.toml README guide](../python/configs/2026-09-14-pyproject-toml-readme.md), [App config](../python/configs/2026-09-15-app-config.yaml), [pyproject.toml config](../python/configs/2026-08-24-pyproject-toml-config.toml)
- **dockerfiles** (1): [Python app Dockerfile](../python/dockerfiles/python-app.Dockerfile)
- **notebooks** (2): most recent → [Async patterns comparison](../python/notebooks/async-patterns-comparison.ipynb) — asyncio vs trio vs anyio for I/O-bound DevOps tooling, [Comparing environment-aware config](../python/notebooks/comparing-env-aware-config.ipynb) — typed settings vs layered loaders vs minimal env readers
- **templates** (8): [Python CLI + Docker + GHA scaffold](../python/templates/python-cli-docker-gha/README.md)
- _…and more under `python/` — browse the folder._

## Terraform  ·  27 files

- **primer:** [Terraform — quick primer](../tf/notes/0000-primer-terraform.md)
- **notes** (4): most recent → [Terraform quickstart trip-ups](../tf/notes/2026-08-27-terraform-quickstart.md), [Quickstart trip-ups](../tf/notes/2026-08-08-quickstart-trip-ups.md), [Install Terraform and run first version command](../tf/notes/2026-07-26-install-terraform-and-run-first-version-command.md)
- **configs** (7): most recent → [AWS VPC NAT module](../tf/configs/aws-vpc-nat-module.hcl), [Multi-resource Terraform config](../tf/configs/multi-resource-terraform-config.hcl), [Terraform null resource](../tf/configs/2026-09-02-first-terraform-null-resource.hcl), [Minimal provider resource](../tf/configs/2026-08-08-minimal-provider-resource.hcl)
- **docs** (3): most recent → [Terraform — coverage check](../tf/docs/2026-08-11-terraform-coverage.md), [Local vs remote Terraform state](../tf/docs/local-vs-remote-terraform-state.md), [Terraform project structure](../tf/docs/2026-08-06-terraform-project-structure.md)
- **scripts** (2): most recent → [Terraform init/validate/plan/apply with lock handling](../tf/scripts/2026-09-04-tf-init-validate-plan-apply-with-lock-handling.sh), [Terraform init, plan, apply](../tf/scripts/2026-08-08-tf-init-plan-apply.sh)
- **snippets** (1): [Terraform variables and outputs](../tf/snippets/2026-08-30-terraform-variables-outputs.hcl)
- **manifests** (1): [Root module fan-out composition](../tf/manifests/root-module-fan-out-composition.hcl) — VPC, EKS, and RDS submodules wired via outputs from one root module
- **notebooks** (1): [State management strategies](../tf/notebooks/state-management-strategies.ipynb)
- **templates** (8): [Terragrunt multi-environment scaffold](../tf/templates/terragrunt-multi-env/README.md) — one reusable module shared across dev, staging, and prod with per-environment inputs · _…and 7 more under `tf/templates/terragrunt-multi-env/`._

## Repo-doc  ·  6 files

- **primer:** [Repo-doc — quick primer](../repo-doc/notes/0000-primer-repo-doc.md)
- **notes** (1): [Repo-task quickstart trip-ups](../repo-doc/notes/2026-09-10-repo-task-quickstart-trip-ups.md)
- **docs** (2): [Repo — reconcile coverage tables with on-disk counts](../repo-doc/docs/2026-08-08-reconcile-coverage-tables.md), [Repo-doc tooling overview](../repo-doc/docs/2026-09-08-repo-doc-tooling-overview.md)
- **scripts** (2): [Regenerate coverage tables](../repo-doc/scripts/2026-09-01-regenerate-coverage-tables.sh), [Minimal task automation](../repo-doc/scripts/2026-09-10-minimal-task-automation.sh)

## Concepts (docs/concepts/)  ·  64 files

Foundational primers on the ideas the tools build on — one primer per concept, plus runnable scripts, snippets, and notebooks. Each folder holds more than the highlights below.

- **CI/CD Pipeline Concepts** (10): [primer](../docs/concepts/ci-cd-pipeline-concepts/0000-primer-ci-cd-pipeline-concepts.md) · [gate-before-merge with branch protection](../docs/concepts/ci-cd-pipeline-concepts/gate-before-merge-branch-protection.md) · [infrastructure validation gates](../docs/concepts/ci-cd-pipeline-concepts/scripts/infrastructure-validation-gates.sh) · notebook: [Pipeline metrics and health dashboards](../docs/concepts/ci-cd-pipeline-concepts/notebooks/pipeline-metrics-and-health-dashboards.ipynb) · _…and 6 more under `docs/concepts/ci-cd-pipeline-concepts/`._
- **Containerization Concepts** (6): [primer](../docs/concepts/containerization-concepts/0000-primer-containerization-concepts.md) · [monitoring containerized apps in production](../docs/concepts/containerization-concepts/monitoring-containerized-apps-in-production.md) · script: [Container observability with the Prometheus node exporter](../docs/concepts/containerization-concepts/scripts/containerization-observability-prometheus-node-exporter.sh) · _…and 3 more under `docs/concepts/containerization-concepts/`._
- **Infrastructure as Code Principles** (7): [primer](../docs/concepts/infrastructure-as-code-principles/0000-primer-infrastructure-as-code-principles.md) · [parameterised config generation](../docs/concepts/infrastructure-as-code-principles/parameterised-config-generation.md) · [state file management strategies](../docs/concepts/infrastructure-as-code-principles/state-file-management-strategies.md) · script: [Network topology Terraform generator](../docs/concepts/infrastructure-as-code-principles/scripts/network-topology-terraform.sh) · _…and 3 more under `docs/concepts/infrastructure-as-code-principles/`._
- **Linux & CLI Fundamentals** (8): [primer](../docs/concepts/linux-cli-fundamentals/0000-primer-linux-cli-fundamentals.md) · [automating network diagnostics from the shell](../docs/concepts/linux-cli-fundamentals/combining-linux-cli-with-networking-automating-network-diagnostics.md) · script: [Provision local VMs with cloud-init](../docs/concepts/linux-cli-fundamentals/scripts/provision-local-vms-with-cloud-init.sh) · notebook: [Exploring connectivity with command-line tools](../docs/concepts/linux-cli-fundamentals/notebooks/exploring-connectivity-with-command-line-tools.ipynb) · _…and 4 more under `docs/concepts/linux-cli-fundamentals/`._
- **Networking Fundamentals** (12): [primer](../docs/concepts/networking-fundamentals/0000-primer-networking-fundamentals.md) · [combining networking with containerization](../docs/concepts/networking-fundamentals/combining-networking-with-containerization.md) · notebook: [Overlay networks and service mesh exploration](../docs/concepts/networking-fundamentals/notebooks/overlay-networks-and-service-mesh-exploration.ipynb) · snippet: [Applying networking in DevOps](../docs/concepts/networking-fundamentals/snippets/2026-08-23-applying-networking-in-devops.py) · script: [Path MTU discovery](../docs/concepts/networking-fundamentals/scripts/2026-08-24-path-mtu-discovery.sh) · _…and 5 more under `docs/concepts/networking-fundamentals/`._
- **Observability & Monitoring Concepts** (8): [primer](../docs/concepts/observability-monitoring-concepts/0000-primer-observability-monitoring-concepts.md) · script: [Observability exercises — round two](../docs/concepts/observability-monitoring-concepts/scripts/2026-08-20-observability-exercises.sh) · script: [CI/CD pipeline metric collection probes](../docs/concepts/observability-monitoring-concepts/scripts/observability-cicd-pipeline-metric-collection-probes.sh) · snippet: [Applying observability in DevOps](../docs/concepts/observability-monitoring-concepts/snippets/2026-08-07-applying-observability-in-devops.py) · _…and 4 more under `docs/concepts/observability-monitoring-concepts/`._
- **Scripting & Automation Philosophy** (6): [primer](../docs/concepts/scripting-automation-philosophy/0000-primer-scripting-automation-philosophy.md) · snippet: [Deploy checklist as data](../docs/concepts/scripting-automation-philosophy/snippets/2026-08-20-scripting-deploy-checklist.py) · script: [Terraform plan/apply, made idempotent](../docs/concepts/scripting-automation-philosophy/scripts/terraform-plan-apply-idempotent.sh) · _…and 3 more under `docs/concepts/scripting-automation-philosophy/`._
- **Version Control & Git Workflow** (7): [primer](../docs/concepts/version-control-git-workflow/0000-primer-version-control-git-workflow.md) · [branch strategy and pipeline triggers](../docs/concepts/version-control-git-workflow/branch-strategy-and-pipeline-triggers.md) · snippet: [Release-readiness commit inventory](../docs/concepts/version-control-git-workflow/snippets/2026-08-20-release-branch-commit-check.py) · snippet: [Correlating commit history with deployments](../docs/concepts/version-control-git-workflow/snippets/analyzing-git-commit-history-for-deployment-correlation.py) · _…and 3 more under `docs/concepts/version-control-git-workflow/`._

## Scripting companion (top level)  ·  1 file

- **configs** (1): [Deploy-checklist companion app config](../scripting-automation-philosophy/configs/2026-09-16-app.yaml) — sample `app.yaml` loaded by the scripting deploy-checklist snippet.
