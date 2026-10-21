# Topics

> A map of what's here. For a beginner-to-advanced reading order, see [learning-path.md](learning-path.md).

## Ansible  ·  56 files

- **primer:** [0000-primer-ansible.md](../ansible/notes/0000-primer-ansible.md)
- **Notes** (3): [2026-08-31-ansible-quickstart-gotchas.md](../ansible/notes/2026-08-31-ansible-quickstart-gotchas.md), [2026-08-10-install-ansible-and-run-first-command.md](../ansible/notes/2026-08-10-install-ansible-and-run-first-command.md), [0000-primer-ansible.md](../ansible/notes/0000-primer-ansible.md)
- **Docs** (7): [wired-handlers-idempotency-fleet.md](../ansible/docs/wired-handlers-idempotency-fleet.md), [retry-strategies-unreliable-targets.md](../ansible/docs/retry-strategies-unreliable-targets.md), [managing-kubernetes-with-ansible.md](../ansible/docs/managing-kubernetes-with-ansible.md)
- _…and 4 more under `ansible/` — browse the folder._
- **Scripts** (5): [ansible-vault-patterns.sh](../ansible/scripts/ansible-vault-patterns.sh), [ansible-playbook-wrapper.sh](../ansible/scripts/ansible-playbook-wrapper.sh), [ansible-playbook-gated-run.sh](../ansible/scripts/ansible-playbook-gated-run.sh)
- _…and 2 more under `ansible/` — browse the folder._
- **Snippets** (1): [block-rescue-always-handlers.yaml](../ansible/snippets/block-rescue-always-handlers.yaml)
- **Configs** (4): [vps-hardening-playbook.yaml](../ansible/configs/vps-hardening-playbook.yaml), [2026-08-31-idempotent-nginx-playbook.yaml](../ansible/configs/2026-08-31-idempotent-nginx-playbook.yaml), [2026-08-22-install-nginx-playbook.yaml](../ansible/configs/2026-08-22-install-nginx-playbook.yaml)
- _…and 1 more under `ansible/` — browse the folder._
- **Manifests** (7): [terraform-dynamic-inventory.yaml](../ansible/manifests/terraform-dynamic-inventory.yaml), [requirements.yml](../ansible/manifests/requirements.yml), [requirements.txt](../ansible/manifests/requirements.txt)
- _…and 4 more under `ansible/` — browse the folder._
- **Notebooks** (1): [execution-modes-comparison.ipynb](../ansible/notebooks/execution-modes-comparison.ipynb)
- **Templates** (28): [verify-ee.sh](../ansible/templates/execution-environment-build-pipeline/verify-ee.sh), [requirements.yml](../ansible/templates/execution-environment-build-pipeline/requirements.yml), [build-ee.sh](../ansible/templates/execution-environment-build-pipeline/build-ee.sh)
- _…and 25 more under `ansible/` — browse the folder._

## AWX  ·  7 files

- **primer:** [0000-primer-awx.md](../awx/notes/0000-primer-awx.md)
- **Notes** (4): [2026-10-11-awx-24-6-quickstart-admin-bootstrap-ee-wiring-allow-jinja-trap.md](../awx/notes/2026-10-11-awx-24-6-quickstart-admin-bootstrap-ee-wiring-allow-jinja-trap.md), [2026-10-07-explore-awx-ui-first-job-template.md](../awx/notes/2026-10-07-explore-awx-ui-first-job-template.md), [2026-10-04-explore-awx-ui-and-api.md](../awx/notes/2026-10-04-explore-awx-ui-and-api.md)
- _…and 1 more under `awx/` — browse the folder._
- **Scripts** (1): [2026-10-20-awx-quickstart.sh](../awx/scripts/2026-10-20-awx-quickstart.sh)
- **Configs** (2): [2026-10-12-execution-environment-mounts-pull-policy.yaml](../awx/configs/2026-10-12-execution-environment-mounts-pull-policy.yaml), [2026-10-07-minimal-awx-custom-resource-minikube.yaml](../awx/configs/2026-10-07-minimal-awx-custom-resource-minikube.yaml)

## Bash  ·  64 files

- **primer:** [0000-primer-bash.md](../bash/notes/0000-primer-bash.md)
- **Notes** (3): [2026-07-23-bash-guide-trip-ups.md](../bash/notes/2026-07-23-bash-guide-trip-ups.md), [2026-07-18-install-bash-and-first-script.md](../bash/notes/2026-07-18-install-bash-and-first-script.md), [0000-primer-bash.md](../bash/notes/0000-primer-bash.md)
- **Docs** (9): [strict-mode-trap-patterns.md](../bash/docs/strict-mode-trap-patterns.md), [production-runbook-strict-mode-pipestatus-shellcheck-ci-gate.md](../bash/docs/production-runbook-strict-mode-pipestatus-shellcheck-ci-gate.md), [production-reference-patterns.md](../bash/docs/production-reference-patterns.md)
- _…and 6 more under `bash/` — browse the folder._
- **Scripts** (12): [trap-library-template.sh](../bash/scripts/trap-library-template.sh), [system-report-tool.sh](../bash/scripts/system-report-tool.sh), [retry-with-circuit-breaker.sh](../bash/scripts/retry-with-circuit-breaker.sh)
- _…and 9 more under `bash/` — browse the folder._
- **Snippets** (3): [parameter-expansion-advanced.sh](../bash/snippets/parameter-expansion-advanced.sh), [coproc-fifo-and-named-variables.sh](../bash/snippets/coproc-fifo-and-named-variables.sh), [comparing-brackets-gotchas.sh](../bash/snippets/comparing-brackets-gotchas.sh)
- **Notebooks** (6): [comparing-shellcheck-profiles.ipynb](../bash/notebooks/comparing-shellcheck-profiles.ipynb), [comparing-pipeline-exit-code-handling.ipynb](../bash/notebooks/comparing-pipeline-exit-code-handling.ipynb), [comparing-log-rotation-approaches.ipynb](../bash/notebooks/comparing-log-rotation-approaches.ipynb)
- _…and 3 more under `bash/` — browse the folder._
- **Dockerfiles** (1): [strict-mode-runner.Dockerfile](../bash/dockerfiles/strict-mode-runner.Dockerfile)
- **Templates** (30): [app.bats](../bash/templates/bash-production-scaffold/tests/app.bats), [retry.sh](../bash/templates/bash-production-scaffold/lib/retry.sh), [logging.sh](../bash/templates/bash-production-scaffold/lib/logging.sh)
- _…and 27 more under `bash/` — browse the folder._

## Compose  ·  6 files

- **primer:** [0000-primer-compose.md](../compose/notes/0000-primer-compose.md)
- **Notes** (3): [2026-10-21-depends-on-healthchecks.md](../compose/notes/2026-10-21-depends-on-healthchecks.md), [2026-10-14-first-compose-up.md](../compose/notes/2026-10-14-first-compose-up.md), [0000-primer-compose.md](../compose/notes/0000-primer-compose.md)
- **Scripts** (1): [2026-10-21-compose-lifecycle.sh](../compose/scripts/2026-10-21-compose-lifecycle.sh)
- **Configs** (2): [2026-10-21-minimal-multi-service-stack.yaml](../compose/configs/2026-10-21-minimal-multi-service-stack.yaml), [2026-10-14-web-plus-db.yaml](../compose/configs/2026-10-14-web-plus-db.yaml)

## Docker  ·  65 files

- **primer:** [0000-primer-docker.md](../docker/notes/0000-primer-docker.md)
- **Notes** (5): [2026-08-06-docker-quickstart-trip-ups.md](../docker/notes/2026-08-06-docker-quickstart-trip-ups.md), [2026-07-19-install-docker.md](../docker/notes/2026-07-19-install-docker.md), [2026-07-15-docker-quickstart-trip-ups.md](../docker/notes/2026-07-15-docker-quickstart-trip-ups.md)
- _…and 2 more under `docker/` — browse the folder._
- **Docs** (5): [storage-drivers-volume-types-comparison.md](../docker/docs/storage-drivers-volume-types-comparison.md), [multi-stage-build-patterns-python-services.md](../docker/docs/multi-stage-build-patterns-python-services.md), [docker-compose-healthcheck-service-ordering.md](../docker/docs/docker-compose-healthcheck-service-ordering.md)
- _…and 2 more under `docker/` — browse the folder._
- **Scripts** (8): [multi-arch-buildx.sh](../docker/scripts/multi-arch-buildx.sh), [image-vuln-scan-policy.sh](../docker/scripts/image-vuln-scan-policy.sh), [image-build-automation.sh](../docker/scripts/image-build-automation.sh)
- _…and 5 more under `docker/` — browse the folder._
- **Manifests** (3): [gitops-image-promotion.yaml](../docker/manifests/gitops-image-promotion.yaml), [gitops-image-build-and-push.yaml](../docker/manifests/gitops-image-build-and-push.yaml), [2026-08-17-multi-service-docker-compose.yaml](../docker/manifests/2026-08-17-multi-service-docker-compose.yaml)
- **Dockerfiles** (5): [production-hardened-python-web-service.Dockerfile](../docker/dockerfiles/production-hardened-python-web-service.Dockerfile), [production-distroless-vuln-gated.Dockerfile](../docker/dockerfiles/production-distroless-vuln-gated.Dockerfile), [production-distroless-sbom.Dockerfile](../docker/dockerfiles/production-distroless-sbom.Dockerfile)
- _…and 2 more under `docker/` — browse the folder._
- **Templates** (36): [index.html](../docker/templates/multi-service-compose-app/web/index.html), [db_password.txt.example](../docker/templates/multi-service-compose-app/secrets/db_password.txt.example), [api_key.txt.example](../docker/templates/multi-service-compose-app/secrets/api_key.txt.example)
- _…and 33 more under `docker/` — browse the folder._
- **Src** (2): [main.go](../docker/src/main.go), [2026-07-16-server.py](../docker/src/2026-07-16-server.py)

## GitHub Actions  ·  36 files

- **primer:** [0000-primer-gha.md](../gha/notes/0000-primer-gha.md)
- **Notes** (3): [2026-08-06-github-actions-quickstart-trip-ups.md](../gha/notes/2026-08-06-github-actions-quickstart-trip-ups.md), [2026-08-05-install-gh-cli.md](../gha/notes/2026-08-05-install-gh-cli.md), [0000-primer-gha.md](../gha/notes/0000-primer-gha.md)
- **Docs** (6): [workflow-security-hardening.md](../gha/docs/workflow-security-hardening.md), [tag-triggered-release-workflows.md](../gha/docs/tag-triggered-release-workflows.md), [oidc-token-exchange.md](../gha/docs/oidc-token-exchange.md)
- _…and 3 more under `gha/` — browse the folder._
- **Scripts** (6): [index.js](../gha/scripts/repository-dispatch-retry/index.js), [action.yml](../gha/scripts/repository-dispatch-retry/action.yml), [minimal-custom-js-action.js](../gha/scripts/minimal-custom-js-action.js)
- _…and 3 more under `gha/` — browse the folder._
- **Snippets** (1): [reusable-workflow-caller.yaml](../gha/snippets/reusable-workflow-caller.yaml)
- **Configs** (11): [action.yml](../gha/configs/shared-shell-ci/action.yml), [shared-shell-ci-caller.yaml](../gha/configs/shared-shell-ci-caller.yaml), [action.yml](../gha/configs/reusable-composite-action/action.yml)
- _…and 8 more under `gha/` — browse the folder._
- **Manifests** (2): [reusable-workflow-ecosystem.yaml](../gha/manifests/reusable-workflow-ecosystem.yaml), [gitops-app-of-apps.yaml](../gha/manifests/gitops-app-of-apps.yaml)
- **Notebooks** (1): [comparing-matrix-vs-single-job-ci-strategies.ipynb](../gha/notebooks/comparing-matrix-vs-single-job-ci-strategies.ipynb)
- **Templates** (6): [reusable-ci.yml](../gha/templates/production-ci-template/reusable-ci.yml), [deploy.yml](../gha/templates/production-ci-template/deploy.yml), [ci.yml](../gha/templates/production-ci-template/ci.yml)
- _…and 3 more under `gha/` — browse the folder._

## Git  ·  66 files

- **primer:** [0000-primer-git.md](../git/notes/0000-primer-git.md)
- **Notes** (16): [2026-09-10-git-companion-readme-quickstart.md](../git/notes/2026-09-10-git-companion-readme-quickstart.md), [2026-09-10-git-companion-readme-primer.txt](../git/notes/2026-09-10-git-companion-readme-primer.txt), [2026-09-10-git-companion-file-quickstart.txt](../git/notes/2026-09-10-git-companion-file-quickstart.txt)
- _…and 13 more under `git/` — browse the folder._
- **Docs** (14): [worktree-parallel-feature-development.md](../git/docs/worktree-parallel-feature-development.md), [worktree-hotfix-isolation.md](../git/docs/worktree-hotfix-isolation.md), [signed-commits-and-ci-provenance.md](../git/docs/signed-commits-and-ci-provenance.md)
- _…and 11 more under `git/` — browse the folder._
- **Scripts** (7): [semantic-release-automation.sh](../git/scripts/semantic-release-automation.sh), [git-repo-health-check.sh](../git/scripts/git-repo-health-check.sh), [git-pr-helper.sh](../git/scripts/git-pr-helper.sh)
- _…and 4 more under `git/` — browse the folder._
- **Manifests** (1): [ci-cd-pipeline-trigger.yaml](../git/manifests/ci-cd-pipeline-trigger.yaml)
- **Notebooks** (1): [choosing-between-merge-squash-and-rebase-strategies.ipynb](../git/notebooks/choosing-between-merge-squash-and-rebase-strategies.ipynb)
- **Templates** (26): [update-changelog.sh](../git/templates/repo-scaffold/scripts/update-changelog.sh), [run-tests.sh](../git/templates/repo-scaffold/scripts/run-tests.sh), [pre-commit](../git/templates/repo-scaffold/hooks/pre-commit)
- _…and 23 more under `git/` — browse the folder._
- **Hooks** (1): [install.sh](../git/hooks/install.sh)

## Grafana  ·  29 files

- **primer:** [0000-primer-grafana.md](../grafana/notes/0000-primer-grafana.md)
- **Notes** (4): [2026-08-27-grafana-quickstart-gotchas.md](../grafana/notes/2026-08-27-grafana-quickstart-gotchas.md), [2026-08-27-first-grafana-web-ui.md](../grafana/notes/2026-08-27-first-grafana-web-ui.md), [2026-08-06-install-grafana.md](../grafana/notes/2026-08-06-install-grafana.md)
- _…and 1 more under `grafana/` — browse the folder._
- **Docs** (2): [unified-alerting-helper-reference.md](../grafana/docs/unified-alerting-helper-reference.md), [prometheus-alertmanager-oncall-pipeline.md](../grafana/docs/prometheus-alertmanager-oncall-pipeline.md)
- **Scripts** (1): [grafana-http-api-dashboard-wrapper.sh](../grafana/scripts/grafana-http-api-dashboard-wrapper.sh)
- **Snippets** (3): [2026-09-09-list-dashboards-datasources.py](../grafana/snippets/2026-09-09-list-dashboards-datasources.py), [2026-08-22-create-dashboard.sh](../grafana/snippets/2026-08-22-create-dashboard.sh), [2026-08-19-list-dashboards.sh](../grafana/snippets/2026-08-19-list-dashboards.sh)
- **Configs** (6): [provisioned-dashboard-panels-variables.yaml](../grafana/configs/provisioned-dashboard-panels-variables.yaml), [2026-08-30-loki-datasource-provisioning.yaml](../grafana/configs/2026-08-30-loki-datasource-provisioning.yaml), [2026-08-29-grafana-datasource-provisioning.yaml](../grafana/configs/2026-08-29-grafana-datasource-provisioning.yaml)
- _…and 3 more under `grafana/` — browse the folder._
- **Manifests** (3): [production-provisioning-datasources-dashboards-alerts.yaml](../grafana/manifests/production-provisioning-datasources-dashboards-alerts.yaml), [kubernetes-persistent-ingress-sidecar.yaml](../grafana/manifests/kubernetes-persistent-ingress-sidecar.yaml), [dashboard-provisioning-grafonnet-jsonnet.yaml](../grafana/manifests/dashboard-provisioning-grafonnet-jsonnet.yaml)
- **Notebooks** (1): [comparing-grafana-unified-alerting-vs-alertmanager.ipynb](../grafana/notebooks/comparing-grafana-unified-alerting-vs-alertmanager.ipynb)
- **Dockerfiles** (1): [grafana-with-plugins-and-provisioned-datasource.Dockerfile](../grafana/dockerfiles/grafana-with-plugins-and-provisioned-datasource.Dockerfile)
- **Templates** (8): [promtail-config.yaml](../grafana/templates/grafana-prometheus-loki-stack/promtail/promtail-config.yaml), [prometheus.yaml](../grafana/templates/grafana-prometheus-loki-stack/prometheus/prometheus.yaml), [loki-config.yaml](../grafana/templates/grafana-prometheus-loki-stack/loki/loki-config.yaml)
- _…and 5 more under `grafana/` — browse the folder._

## Helm Charts  ·  4 files

- **primer:** [0000-primer-hchart.md](../hchart/notes/0000-primer-hchart.md)
- **Notes** (2): [2026-10-14-explore-public-chart-structure.md](../hchart/notes/2026-10-14-explore-public-chart-structure.md), [0000-primer-hchart.md](../hchart/notes/0000-primer-hchart.md)
- **Configs** (2): [2026-10-14-minimal-values.yaml](../hchart/configs/2026-10-14-minimal-values.yaml), [2026-10-14-minimal-chart.yaml](../hchart/configs/2026-10-14-minimal-chart.yaml)

## Helm  ·  54 files

- **primer:** [0000-primer-helm.md](../helm/notes/0000-primer-helm.md)
- **Notes** (6): [2026-09-21-values-merge-set-vs-file.md](../helm/notes/2026-09-21-values-merge-set-vs-file.md), [2026-08-19-following-helm-quickstart.md](../helm/notes/2026-08-19-following-helm-quickstart.md), [2026-08-18-install-helm-with-package-manager.md](../helm/notes/2026-08-18-install-helm-with-package-manager.md)
- _…and 3 more under `helm/` — browse the folder._
- **Docs** (5): [helm-values-inheritance.md](../helm/docs/helm-values-inheritance.md), [helm-production-best-practices.md](../helm/docs/helm-production-best-practices.md), [helm-migration-guide.md](../helm/docs/helm-migration-guide.md)
- _…and 2 more under `helm/` — browse the folder._
- **Scripts** (3): [helm-release-workflow.sh](../helm/scripts/helm-release-workflow.sh), [2026-07-31-install-helm-run-version.sh](../helm/scripts/2026-07-31-install-helm-run-version.sh), [2026-07-31-deploy-first-chart.sh](../helm/scripts/2026-07-31-deploy-first-chart.sh)
- **Snippets** (1): [2026-07-31-deploy-first-chart.sh](../helm/snippets/2026-07-31-deploy-first-chart.sh)
- **Configs** (7): [multi-environment-helm-values.yaml](../helm/configs/multi-environment-helm-values.yaml), [chart-scaffold.yaml](../helm/configs/chart-scaffold.yaml), [2026-09-21-minimal-static-web-app-values.yaml](../helm/configs/2026-09-21-minimal-static-web-app-values.yaml)
- _…and 4 more under `helm/` — browse the folder._
- **Manifests** (3): [production-multi-tier-deployment.yaml](../helm/manifests/production-multi-tier-deployment.yaml), [hooks-lifecycle.yaml](../helm/manifests/hooks-lifecycle.yaml), [2026-08-14-first-chart-template.yaml](../helm/manifests/2026-08-14-first-chart-template.yaml)
- **Notebooks** (1): [comparing-helm-values-merging.ipynb](../helm/notebooks/comparing-helm-values-merging.ipynb)
- **Templates** (28): [values.yaml](../helm/templates/polished-chart/values.yaml), [values.schema.json](../helm/templates/polished-chart/values.schema.json), [service.yaml](../helm/templates/polished-chart/templates/service.yaml)
- _…and 25 more under `helm/` — browse the folder._

## Jenkins  ·  62 files

- **primer:** [0000-primer-jenkins.md](../jenkins/notes/0000-primer-jenkins.md)
- **Notes** (5): [2026-09-22-first-controller-plugins-agents-credentials.md](../jenkins/notes/2026-09-22-first-controller-plugins-agents-credentials.md), [2026-09-06-followed-jenkins-tutorial.md](../jenkins/notes/2026-09-06-followed-jenkins-tutorial.md), [2026-09-03-quickstart-follow-up.md](../jenkins/notes/2026-09-03-quickstart-follow-up.md)
- _…and 2 more under `jenkins/` — browse the folder._
- **Docs** (4): [moving-jenkinsfile-to-scm-gotchas.md](../jenkins/docs/moving-jenkinsfile-to-scm-gotchas.md), [moving-jenkinsfile-from-inline-to-scm-script-path-branch-lightweight-checkout-credential-gotchas.md](../jenkins/docs/moving-jenkinsfile-from-inline-to-scm-script-path-branch-lightweight-checkout-credential-gotchas.md), [integrating-jenkins-github-actions-argocd-progressive-delivery.md](../jenkins/docs/integrating-jenkins-github-actions-argocd-progressive-delivery.md)
- _…and 1 more under `jenkins/` — browse the folder._
- **Scripts** (2): [common-cicd-shared-library.groovy](../jenkins/scripts/common-cicd-shared-library.groovy), [2026-09-22-nodejs-jenkinsfile.groovy](../jenkins/scripts/2026-09-22-nodejs-jenkinsfile.groovy)
- **Snippets** (3): [2026-09-19-shared-library-credentials.groovy](../jenkins/snippets/2026-09-19-shared-library-credentials.groovy), [2026-09-05-environment-credentials-pipeline.groovy](../jenkins/snippets/2026-09-05-environment-credentials-pipeline.groovy), [2026-08-11-hello-world-pipeline.groovy](../jenkins/snippets/2026-08-11-hello-world-pipeline.groovy)
- **Configs** (3): [jenkins-casc-reproducible-controller-setup.yaml](../jenkins/configs/jenkins-casc-reproducible-controller-setup.yaml), [jenkins-casc-ha.yaml](../jenkins/configs/jenkins-casc-ha.yaml), [2026-09-05-minimal-declarative-jenkinsfile.jenkinsfile](../jenkins/configs/2026-09-05-minimal-declarative-jenkinsfile.jenkinsfile)
- **Templates** (45): [sendSlackNotification.groovy](../jenkins/templates/shared-library-reusable-steps-dsl-scaffold/vars/sendSlackNotification.groovy), [runLint.groovy](../jenkins/templates/shared-library-reusable-steps-dsl-scaffold/vars/runLint.groovy), [buildImage.groovy](../jenkins/templates/shared-library-reusable-steps-dsl-scaffold/vars/buildImage.groovy)
- _…and 42 more under `jenkins/` — browse the folder._

## Kubernetes  ·  47 files

- **primer:** [0000-primer-kubernetes.md](../k8s/notes/0000-primer-kubernetes.md)
- **Notes** (6): [2026-10-05-first-kubectl-commands-and-cluster-explore.md](../k8s/notes/2026-10-05-first-kubectl-commands-and-cluster-explore.md), [2026-09-16-quickstart-kind-contexts-and-port-mismatch.md](../k8s/notes/2026-09-16-quickstart-kind-contexts-and-port-mismatch.md), [2026-08-04-kubernetes-quickstart-tripped-up.md](../k8s/notes/2026-08-04-kubernetes-quickstart-tripped-up.md)
- _…and 3 more under `k8s/` — browse the folder._
- **Docs** (6): [kubernetes-helm-argocd-gitops-workflow.md](../k8s/docs/kubernetes-helm-argocd-gitops-workflow.md), [kubectl-imperative-vs-declarative.md](../k8s/docs/kubectl-imperative-vs-declarative.md), [integrating-kubernetes-with-terraform.md](../k8s/docs/integrating-kubernetes-with-terraform.md)
- _…and 3 more under `k8s/` — browse the folder._
- **Scripts** (3): [multi-pod-deployment.sh](../k8s/scripts/multi-pod-deployment.sh), [2026-08-03-install-minikube-and-run-kubectl-version.sh](../k8s/scripts/2026-08-03-install-minikube-and-run-kubectl-version.sh), [2026-08-02-install-minikube-and-run-kubectl-version.sh](../k8s/scripts/2026-08-02-install-minikube-and-run-kubectl-version.sh)
- **Snippets** (2): [kubectl-pod-metrics.py](../k8s/snippets/kubectl-pod-metrics.py), [2026-08-19-list-cluster-resources.sh](../k8s/snippets/2026-08-19-list-cluster-resources.sh)
- **Configs** (1): [2026-08-22-first-deployment.yaml](../k8s/configs/2026-08-22-first-deployment.yaml)
- **Manifests** (6): [zero-downtime-rolling-deployment.yaml](../k8s/manifests/zero-downtime-rolling-deployment.yaml), [stateless-workload-spread-hpa-pdb.yaml](../k8s/manifests/stateless-workload-spread-hpa-pdb.yaml), [production-deployment.yaml](../k8s/manifests/production-deployment.yaml)
- _…and 3 more under `k8s/` — browse the folder._
- **Notebooks** (2): [service-mesh-ingress-dns-networking.ipynb](../k8s/notebooks/service-mesh-ingress-dns-networking.ipynb), [comparing-kubernetes-rollout-strategies.ipynb](../k8s/notebooks/comparing-kubernetes-rollout-strategies.ipynb)
- **Dockerfiles** (1): [operator-dev.Dockerfile](../k8s/dockerfiles/operator-dev.Dockerfile)
- **Templates** (20): [verify.sh](../k8s/templates/production-service/verify.sh), [serviceaccount.yaml](../k8s/templates/production-service/serviceaccount.yaml), [service.yaml](../k8s/templates/production-service/service.yaml)
- _…and 17 more under `k8s/` — browse the folder._

## Kube-Prometheus  ·  5 files

- **primer:** [0000-primer-kube-prometheus.md](../kprom/notes/0000-primer-kube-prometheus.md)
- **Notes** (3): [2026-10-10-quickstart-walkthrough-kube-prometheus-stack.md](../kprom/notes/2026-10-10-quickstart-walkthrough-kube-prometheus-stack.md), [2026-10-08-install-kube-prometheus-stack-and-explore-grafana.md](../kprom/notes/2026-10-08-install-kube-prometheus-stack-and-explore-grafana.md), [0000-primer-kube-prometheus.md](../kprom/notes/0000-primer-kube-prometheus.md)
- **Configs** (1): [2026-10-08-minimal-kube-prometheus-local-values.yaml](../kprom/configs/2026-10-08-minimal-kube-prometheus-local-values.yaml)
- **Manifests** (1): [2026-10-12-servicemonitor-prometheusrule-red-metrics.yaml](../kprom/manifests/2026-10-12-servicemonitor-prometheusrule-red-metrics.yaml)

## Prometheus  ·  31 files

- **primer:** [0000-primer-prometheus.md](../prom/notes/0000-primer-prometheus.md)
- **Notes** (4): [2026-08-30-prometheus-quickstart-trip-ups.md](../prom/notes/2026-08-30-prometheus-quickstart-trip-ups.md), [2026-08-29-install-prometheus-explore-web-ui.md](../prom/notes/2026-08-29-install-prometheus-explore-web-ui.md), [2026-08-07-install-and-explore-web-ui.md](../prom/notes/2026-08-07-install-and-explore-web-ui.md)
- _…and 1 more under `prom/` — browse the folder._
- **Docs** (4): [promql-advanced-patterns.md](../prom/docs/promql-advanced-patterns.md), [prometheus-operations-runbook.md](../prom/docs/prometheus-operations-runbook.md), [hybrid-service-discovery.md](../prom/docs/hybrid-service-discovery.md)
- _…and 1 more under `prom/` — browse the folder._
- **Scripts** (2): [rules-evaluator.go](../prom/scripts/rules-evaluator.go), [2026-09-03-prom-query-helper.sh](../prom/scripts/2026-09-03-prom-query-helper.sh)
- **Snippets** (1): [2026-08-19-first-promql-query.sh](../prom/snippets/2026-08-19-first-promql-query.sh)
- **Configs** (8): [remote-write-vs-federation.yaml](../prom/configs/remote-write-vs-federation.yaml), [remote-write-long-term-storage.yaml](../prom/configs/remote-write-long-term-storage.yaml), [recording-rules-slo-alerting.yaml](../prom/configs/recording-rules-slo-alerting.yaml)
- _…and 5 more under `prom/` — browse the folder._
- **Manifests** (2): [local-monitoring-stack.yaml](../prom/manifests/local-monitoring-stack.yaml), [k8s-service-discovery-recording-rules-alertmanager.yaml](../prom/manifests/k8s-service-discovery-recording-rules-alertmanager.yaml)
- **Templates** (10): [recording-rules.yml](../prom/templates/prometheus-grafana-alertmanager-stack/prometheus/rules/recording-rules.yml), [alert-rules.yml](../prom/templates/prometheus-grafana-alertmanager-stack/prometheus/rules/alert-rules.yml), [prometheus.yml](../prom/templates/prometheus-grafana-alertmanager-stack/prometheus/prometheus.yml)
- _…and 7 more under `prom/` — browse the folder._

## Python  ·  48 files

- **primer:** [0000-primer-python.md](../python/notes/0000-primer-python.md)
- **Notes** (3): [2026-08-22-python-quickstart-gotchas.md](../python/notes/2026-08-22-python-quickstart-gotchas.md), [2026-08-04-python-functions-modules.md](../python/notes/2026-08-04-python-functions-modules.md), [0000-primer-python.md](../python/notes/0000-primer-python.md)
- **Docs** (4): [python-github-actions-integration.md](../python/docs/python-github-actions-integration.md), [python-docker-ci-pipeline.md](../python/docs/python-docker-ci-pipeline.md), [comparing-python-configuration-approaches.md](../python/docs/comparing-python-configuration-approaches.md)
- _…and 1 more under `python/` — browse the folder._
- **Scripts** (4): [config-validator.py](../python/scripts/config-validator.py), [config-loader-pydantic-settings.py](../python/scripts/config-loader-pydantic-settings.py), [2026-08-04-minimal-file-processing.py](../python/scripts/2026-08-04-minimal-file-processing.py)
- _…and 1 more under `python/` — browse the folder._
- **Snippets** (5): [validate-dockerfile.py](../python/snippets/validate-dockerfile.py), [migration-match-except-star-taskgroup.py](../python/snippets/migration-match-except-star-taskgroup.py), [docker-compose-validator.py](../python/snippets/docker-compose-validator.py)
- _…and 2 more under `python/` — browse the folder._
- **Configs** (4): [2026-09-16-app-config.yaml](../python/configs/2026-09-16-app-config.yaml), [2026-09-15-app-config.yaml](../python/configs/2026-09-15-app-config.yaml), [2026-09-14-pyproject-toml-readme.md](../python/configs/2026-09-14-pyproject-toml-readme.md)
- _…and 1 more under `python/` — browse the folder._
- **Notebooks** (3): [comparing-env-aware-config.ipynb](../python/notebooks/comparing-env-aware-config.ipynb), [asyncio-threading-multiprocessing-decision-guide.ipynb](../python/notebooks/asyncio-threading-multiprocessing-decision-guide.ipynb), [async-patterns-comparison.ipynb](../python/notebooks/async-patterns-comparison.ipynb)
- **Dockerfiles** (1): [python-app.Dockerfile](../python/dockerfiles/python-app.Dockerfile)
- **Templates** (24): [test_items.py](../python/templates/python-service-scaffold/tests/test_items.py), [test_health.py](../python/templates/python-service-scaffold/tests/test_health.py), [conftest.py](../python/templates/python-service-scaffold/tests/conftest.py)
- _…and 21 more under `python/` — browse the folder._

## Repo-doc  ·  28 files

- **primer:** [0000-primer-repo-doc.md](../repo-doc/notes/0000-primer-repo-doc.md)
- **Notes** (5): [2026-10-03-exploring-task-folder-structure.md](../repo-doc/notes/2026-10-03-exploring-task-folder-structure.md), [2026-09-23-following-repo-task-tutorial-workflows.md](../repo-doc/notes/2026-09-23-following-repo-task-tutorial-workflows.md), [2026-09-21-repo-doc-cli-install-and-scaffold.md](../repo-doc/notes/2026-09-21-repo-doc-cli-install-and-scaffold.md)
- _…and 2 more under `repo-doc/` — browse the folder._
- **Docs** (6): [kit-conformance-in-ci.md](../repo-doc/docs/kit-conformance-in-ci.md), [closing-dead-index-and-coverage-references.md](../repo-doc/docs/closing-dead-index-and-coverage-references.md), [2026-10-18-reconcile-primer-with-current-layout.md](../repo-doc/docs/2026-10-18-reconcile-primer-with-current-layout.md)
- _…and 3 more under `repo-doc/` — browse the folder._
- **Scripts** (7): [repo-doc-new-tool.sh](../repo-doc/scripts/repo-doc-new-tool.sh), [project-validator.py](../repo-doc/scripts/project-validator.py), [kit-conformance-checker.py](../repo-doc/scripts/kit-conformance-checker.py)
- _…and 4 more under `repo-doc/` — browse the folder._
- **Snippets** (1): [2026-10-15-stale-branch-cleanup.sh](../repo-doc/snippets/2026-10-15-stale-branch-cleanup.sh)
- **Configs** (3): [repo-doc-cli-config.yaml](../repo-doc/configs/repo-doc-cli-config.yaml), [project-configuration-schema.yaml](../repo-doc/configs/project-configuration-schema.yaml), [2026-09-26-tool-folder-conventions.md](../repo-doc/configs/2026-09-26-tool-folder-conventions.md)
- **Templates** (6): [repo-doc-new-tool.sh](../repo-doc/templates/repo-doc-new-tool-integration-starter-kit/scripts/repo-doc-new-tool.sh), [2026-09-01-regenerate-coverage-tables.sh](../repo-doc/templates/repo-doc-new-tool-integration-starter-kit/scripts/2026-09-01-regenerate-coverage-tables.sh), [tool-folder-conventions.yaml](../repo-doc/templates/repo-doc-new-tool-integration-starter-kit/configs/tool-folder-conventions.yaml)
- _…and 3 more under `repo-doc/` — browse the folder._

## Terraform  ·  57 files

- **primer:** [0000-primer-terraform.md](../tf/notes/0000-primer-terraform.md)
- **Notes** (4): [2026-08-27-terraform-quickstart.md](../tf/notes/2026-08-27-terraform-quickstart.md), [2026-08-08-quickstart-trip-ups.md](../tf/notes/2026-08-08-quickstart-trip-ups.md), [2026-07-26-install-terraform-and-run-first-version-command.md](../tf/notes/2026-07-26-install-terraform-and-run-first-version-command.md)
- _…and 1 more under `tf/` — browse the folder._
- **Docs** (5): [terraform-github-actions-plan-apply-pipeline-remote-backend-environment-approvals.md](../tf/docs/terraform-github-actions-plan-apply-pipeline-remote-backend-environment-approvals.md), [module-composition-patterns.md](../tf/docs/module-composition-patterns.md), [local-vs-remote-terraform-state.md](../tf/docs/local-vs-remote-terraform-state.md)
- _…and 2 more under `tf/` — browse the folder._
- **Scripts** (3): [tf-validation-gate.sh](../tf/scripts/tf-validation-gate.sh), [2026-09-04-tf-init-validate-plan-apply-with-lock-handling.sh](../tf/scripts/2026-09-04-tf-init-validate-plan-apply-with-lock-handling.sh), [2026-08-08-tf-init-plan-apply.sh](../tf/scripts/2026-08-08-tf-init-plan-apply.sh)
- **Snippets** (1): [2026-08-30-terraform-variables-outputs.hcl](../tf/snippets/2026-08-30-terraform-variables-outputs.hcl)
- **Configs** (7): [reusable-vpc-module.hcl](../tf/configs/reusable-vpc-module.hcl), [multi-resource-terraform-config.hcl](../tf/configs/multi-resource-terraform-config.hcl), [aws-vpc-nat-module.hcl](../tf/configs/aws-vpc-nat-module.hcl)
- _…and 4 more under `tf/` — browse the folder._
- **Manifests** (2): [versioned-vpc-module.hcl](../tf/manifests/versioned-vpc-module.hcl), [root-module-fan-out-composition.hcl](../tf/manifests/root-module-fan-out-composition.hcl)
- **Notebooks** (1): [state-management-strategies.ipynb](../tf/notebooks/state-management-strategies.ipynb)
- **Templates** (34): [terragrunt.hcl](../tf/templates/terragrunt-multi-env/terragrunt.hcl), [variables.tf](../tf/templates/terragrunt-multi-env/modules/app-config/variables.tf), [outputs.tf](../tf/templates/terragrunt-multi-env/modules/app-config/outputs.tf)
- _…and 31 more under `tf/` — browse the folder._

## Terraform Cloud  ·  3 files

- **primer:** [0000-primer-tfc.md](../tfc/notes/0000-primer-tfc.md)
- **Notes** (2): [2026-10-14-explore-workspaces.md](../tfc/notes/2026-10-14-explore-workspaces.md), [0000-primer-tfc.md](../tfc/notes/0000-primer-tfc.md)
- **Configs** (1): [2026-10-14-minimal-cloud-backend.hcl](../tfc/configs/2026-10-14-minimal-cloud-backend.hcl)

