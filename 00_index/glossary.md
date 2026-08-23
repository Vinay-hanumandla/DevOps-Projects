# Glossary

## Ansible

- **Control node** — the machine where Ansible runs and from which it connects to managed nodes over SSH.
- **Managed node** — any machine Ansible controls remotely; typically a Linux server reachable via SSH.
- **Playbook** — a YAML file that lists the automated steps to run against hosts; the primary Ansible unit of work.
- **Inventory** — the list of managed nodes Ansible connects to, expressed as a static file or dynamic source.
- **Module** — a reusable chunk of code that performs one job (e.g. `apt`, `copy`, `service`); modules are the building blocks of tasks.
- **Task** — a single call to a module inside a playbook, with a name and any arguments the module needs.
- **Role** — a grouping of tasks, files, templates, and variables meant to be reused across playbooks.
- **Host key checking** — Ansible's refusal to connect to unknown SSH hosts by default; disable with `host_key_checking = False` in `ansible.cfg` for lab use.
- **Fact** — information Ansible collects about a host (CPU, RAM, OS) and exposes as `ansible_facts` in templates and conditions.
- **pipx** — a tool for installing Python applications in isolated environments; the recommended way to install Ansible on systems that block `pip install` (PEP 668).
- **Ad-hoc command** — a single `ansible` command run directly against hosts (e.g. `ansible all -m ping`) without a playbook file; useful for quick checks and one-off actions.

## Docker

- **Image** — an immutable, layered template (built from a Dockerfile) that defines a container's filesystem and start command.
- **Container** — a running instance of an image; isolated but ephemeral, so anything written inside is lost when it stops unless a volume is mounted.
- **Tag** — a label on an image (e.g. `nginx:1.25`); pulling without one defaults to `:latest`, which is why pinning a version matters for reproducibility.
- **Port mapping** — binding a host port to a container port with `-p host:container` (host port first); `docker port <container>` shows the resolved mapping.
- **Detached mode** — running a container with `-d` so it runs in the background instead of holding the terminal; view its output later with `docker logs <container>`.
- **Multi-stage build** — using several `FROM` stages in one Dockerfile to build in a heavy toolchain image and copy only the compiled artifact into a small final image.
- **Distroless image** — a minimal final image containing only the app and its runtime dependencies (no shell, package manager, or OS utilities), which shrinks attack surface.
- **Non-root runtime** — configuring the container to run as an unprivileged UID instead of root, a basic security hardening step.
- **Volume** — a persistent, host-managed storage mount that survives container restarts, used when data must outlive the container.
- **Dockerfile** — a recipe for building an image; each instruction (`FROM`, `RUN`, `COPY`) creates a cached layer.
- **Daemon / Engine** — the background process (`dockerd`) that manages images, containers, networks, and volumes; the `docker` CLI talks to it via a socket.
- **Registry** — a server that stores and distributes images; Docker Hub is the default public registry.
- **Layer** — each instruction in a Dockerfile creates a layer; Docker caches layers so rebuilding is fast when only the last few instructions changed.
- **Manifest** — the JSON document that describes an image's layers, config, and platform (Docker V2 or OCI format); `docker manifest inspect <image>` shows it.
 - **docker compose** — Docker's built-in multi-container orchestration tool (V2); define services in a `compose.yaml` and start everything with `docker compose up`.
 - **Sidecar** — a secondary container that runs alongside the main application container in the same Pod or Compose service, sharing its lifecycle and volumes; used to offload cross-cutting concerns like logging, metrics collection, or proxying without baking them into the app image.
 - **Health check** — a command a container runs periodically to report its own liveness; Docker tracks the status (`starting`/`healthy`/`unhealthy`), and Compose's `depends_on: condition: service_healthy` plus host-side `docker inspect` polling use it to sequence startup between services.

## Bash

- **Shell** — the program that reads typed commands and runs them; Bash is the most common Unix/Linux shell.
- **Script** — a text file containing Bash commands, usually with a `.sh` extension, run with `bash script.sh` or `./script.sh` after making it executable.
- **Variable** — a named value, set with `name="value"` and read with `$name`.
- **Pipe (`|`)** — sends the output of one command as input to another (e.g. `ls | grep ".md"`).
- **Exit code** — every command returns a number: 0 means success, non-zero means failure.
- **`$PATH`** — a colon-separated list of directories where the shell looks for executables.
- **Shebang** — the first line of a script (`#!/usr/bin/env bash`) that tells the system which interpreter to use.
- **`$?`** — the exit code of the last foreground command; useful for inline error checks without an explicit `if`.
- **Entrypoint** — the container command that runs before `exec "$@"`, executing single-purpose start hooks from a directory like `docker-entrypoint.d/` in order; the real process becomes PID 1, mirroring the official nginx/postgres init scripts.
- **Start hook** — a small executable script dropped into `docker-entrypoint.d/` that runs at container start before the main command; one hook per concern (env prep, config checks, waiting on a dependency).
- **Toolchain container** — a dev image that carries all build/test tooling (shellcheck, shfmt, bats, coreutils); the host installs only Docker, and CI runs the exact same environment as local dev.
- **bats** — Bash Automated Testing System, a TAP-compliant test runner for shell scripts; `common_test.bats` exercises `lib/common.sh` by mocking external commands via `PATH`.
- **`exec "$@"`** — replacing the shell process with the container's real command so it runs as PID 1 and receives signals directly, instead of being a child the shell must forward signals to.
- **Stderr** — the separate output stream (`>&2`) for error messages, distinct from normal output (stdout); redirecting it independently keeps diagnostics from polluting a command's real output.
- **Positional parameters** — the arguments passed to a script or function, accessed as `$1`, `$2`, etc.; `$@` holds all of them as separate words, `$*` as a single string.
- **Word splitting** — the shell's behaviour of splitting unquoted variable expansions on characters in `$IFS` (space, tab, newline by default), which causes bugs when a value contains spaces unless quoted.
- **IFS** — the Internal Field Separator, used by the shell to split words after expansion; overriding it (e.g. `IFS=,`) changes how `read` and loops parse delimited input.
- **`trap`** — a builtin that registers a command to run when the shell receives a signal or event (e.g. `EXIT`, `ERR`, `SIGINT`), used for cleanup and error handling.
- **Strict mode** — the Bash safeguard combo `set -Eeuo pipefail`: exit on error, treat unset variables as fatal, fail the whole pipeline if any command in it fails, and inherit error trapping through subshells. Containerised runners and entry points apply it up front so a failing script can't ship a green result.
- **`/dev/tcp`** — Bash's built-in TCP pseudo-device; a redirection like `< /dev/tcp/host/port` succeeds only when the port accepts a connection, so a script can probe reachability with a bounded `timeout` without needing `nc` installed.
- **`paste`** — a coreutils tool that joins the corresponding lines of two or more files side by side; useful for lining up two separately captured metric streams so they can be read as one table.


## Git

- **Repository** — the folder Git is tracking, plus the hidden `.git` database that stores all history.
- **Working tree** — the actual files on disk that you edit, as opposed to the committed snapshots stored in `.git`.
- **Staging area (index)** — the intermediate holding place between your working directory and a commit; `git add` moves changes here, `git commit` snapshots them.
- **Commit** — a snapshot of the staged changes with an author stamp and message; the unit of history in a repository.
- **Branch** — a movable pointer to a commit; `git switch <name>` creates the context where new commits land without touching other lines of work.
- **HEAD** — the currently checked-out commit/branch; commands like `git reset` and `git restore` resolve "here" against it.
- **Remote** — another copy of the repository (usually `origin`); `git push` sends commits to it and `git fetch`/`pull` brings theirs in.
- **Upstream tracking** — a branch's remembered remote counterpart, set with `git push -u`, so later `git push`/`git pull` need no extra arguments.
- **Stash** — a scratch holding area for uncommitted changes (`git stash`) so you can switch context and reapply them later with `git stash pop`.
- **Revert** — `git revert <commit>` makes a new commit that undoes an earlier one; safe on shared branches because it doesn't rewrite history.
- **Reset** — `git reset` moves HEAD (and optionally the index/working tree); `--soft` keeps changes staged, `--hard` discards them, so use it with care.
- **Amend** — `git commit --amend` rewrites the most recent commit (message or contents); fine locally, dangerous once pushed.
- **Patch staging** — `git add -p` stages only selected hunks of a file so unrelated edits can land in separate commits.
- **Rebase** — replaying your commits on top of another branch (e.g. `git rebase main`); linearises history but rewrites commit hashes, so avoid it on shared branches without coordination.
- **Hook** — a script in `.git/hooks/` that Git runs automatically at a named point in its workflow (e.g. `pre-commit`, `pre-push`); used for linting, testing, or enforcing policy before a Git operation completes.
- **Feature branch** — a short-lived branch dedicated to a single change or feature; typically rebased onto `main` before merging to keep history clean.
- **`VERSION` file** — a plain-text file holding the current release number as the single source of truth; `release.sh` reads it, computes the next value, writes it back, and tags the result so versioning lives in the repo rather than in tooling.
- **Annotated tag** — a Git tag with an attached message and tagger metadata (`git tag -a v1.2.3 -m "…"`); unlike a lightweight tag it records who and when, which keeps `git describe` and changelog tooling unambiguous.
- **Version bump (major/minor/patch)** — increasing the meaningful part of a semver `X.Y.Z`; `make patch` → `0.1.1`, `make minor` → `0.2.0`, `make major` → `1.0.0`, driven by `release.sh` computing `next_version`.
- **Dirty working tree** — a working tree with uncommitted changes; the release workflow's `assert_clean_tree` guard refuses to tag a release over half-committed work.
- **Conventional commit** — a commit-message convention where the subject starts with a type such as `feat:`, `fix:`, `docs:`, or `chore:`; a changelog helper buckets commits by that prefix to assemble release notes.
- **Commit range (`<a>..<b>`)** — the set of commits reachable from `<b>` but not from `<a>`; `git log origin/release..main` therefore lists exactly what has landed on `main` but has not yet reached the release branch.
- **Release branch** — a long-lived branch that carries what is currently shipped or about to ship, kept separate from `main` so fixes can be selected into a release without dragging in unfinished work.


## Helm

- **Helm** — a package manager for Kubernetes that defines, installs, and upgrades complex applications using charts.
- **Chart** — a Helm package containing templates and default values; `helm install myapp ./mychart/` renders and deploys everything in that chart.
- **Release** — a running instance of a chart in a cluster; installing the same chart twice with different names gives you two releases.
- **Values file** — a YAML file that overrides a chart's defaults; `helm install myapp ./mychart/ -f custom-values.yaml` applies custom configuration.
- **Repository** — a hosted collection of charts others can use; `helm repo add stable https://charts.helm.sh/stable` registers one.
- **Helmfile** — a declarative file that lists multiple releases to deploy as one group, like a lockfile for Helm.
- **Dependency** — a chart can depend on other charts; your app chart might pull in a Redis chart and a PostgreSQL chart.
- **`helm status`** — a command that reports a release's real health from the cluster, which is more reliable than guessing from `kubectl get all` when pods land in an unexpected namespace.
- **`helm upgrade`** — applies values/template changes to an existing release; editing `values.yaml` on disk does nothing until you run it.

## Python

- **Type** — the category of a value (`int`, `float`, `str`, `bool`, `list`, `dict`); `type(value)` returns it, and knowing it prevents surprises like `5 / 2` giving `2.5` instead of `2`.
- **Virtual environment (venv)** — an isolated directory containing its own Python interpreter and installed packages; created with `python -m venv .venv` so nothing leaks in or out between projects.
- **pip** — Python's package installer; `pip install requests` fetches and installs a library, usually combined with a venv to keep dependencies reproducible.
- **Module** — a `.py` file containing functions, classes, or constants; `import os` loads the built-in `os` module for filesystem and environment access.
- **f-string** — a string with `f""` containing `{}` placeholders evaluated at runtime; faster and more readable than the older `.format()` style.
- **Package** — a directory with `__init__.py` that groups related modules together; the `__init__.py` marks the directory as importable.
- **`sys.path`** — the ordered list of directories Python searches when resolving an `import` statement; includes the current directory, standard library paths, and site-packages.
- **`sys.modules`** — the internal cache of already-loaded modules; editing a file on disk does not invalidate this cache, so `import` reuses the stale module until it is explicitly reloaded.
- **`__init__.py`** — a file that runs when a package is first imported; can control what gets exported via `__all__` and can trigger side effects (which should generally be avoided).
- **Namespace package** — a directory without `__init__.py` that Python 3.3+ can still import; it does not run initialization code and is useful for splitting a single package across multiple locations.
- **Circular import** — when module A imports module B and module B imports module A, causing one of them to see a half-initialized namespace; the fix is to move shared code to a third module that neither depends on.
- **Mutable default argument** — a default parameter value that is a mutable object like `[]` or `{}`; it persists across function calls, causing surprising shared state — the fix is to use `None` as the default and create the mutable object inside the function body.
- **Wildcard import** — `from module import *` imports all public names into the current namespace; it pollutes the namespace and makes it hard to trace where a name comes from, so explicit imports are preferred.

## Terraform

- **Provider** — a plugin that knows how to talk to a specific cloud or service. Example: the AWS provider lets Terraform create EC2 instances and S3 buckets.
- **Resource** — a single piece of infrastructure declared in a config file. Example: `aws_instance.example` represents a virtual machine.
- **State file** — Terraform's record of what it has created. It maps config files to real resources so Terraform knows what to update or skip.
- **Plan** — Terraform's preview of what changes it will make before applying them. Run `terraform plan` to review the diff before committing changes.
- **Apply** — the command that makes the planned changes real. After approving the plan, `terraform apply` creates or updates resources.
- **Drift** — the gap between the real-world state of infrastructure and what Terraform's state file says exists; detected when the actual resources have changed outside Terraform.
- **Declarative** — describing the desired end state rather than the steps to reach it; Terraform configs are declarative, so you say what you want and Terraform figures out how to get there.

## Jenkins

- **Job** — a single unit of work you've defined for Jenkins to run. Example: "build the backend, run the unit tests."
- **Pipeline** — a job defined as code in a `Jenkinsfile`, describing stages like checkout → build → test → deploy. Example: a `pipeline { stages { … } }` block.
- **Node** — a machine Jenkins can run jobs on. Example: the main Jenkins server, or a separate agent you connect to it.
- **Executor** — a slot on a node for running one job step at a time. Example: a node with 2 executors can run 2 jobs concurrently.
- **Plugin** — an add-on that gives Jenkins new capabilities (Git integration, Docker, Slack notifications). Example: the "Git plugin" that lets a job clone a repo.
- **Workspace** — the folder on a node where Jenkins checks out the code for a job and runs the steps. Example: `…/workspace/<job-name>/src/`.
- **Build** — one execution of a job. Example: "build #42" is the 42nd time the job ran.
- **Trigger** — what causes a build to start. Example: a webhook fired when a commit is pushed, or a cron schedule.
- **Console output** — the full log of what a build printed while running. Example: checking this when a test fails to see the failure message.
- **Jenkinsfile** — the pipeline-as-code file living in the repo so job definitions are versioned. Example: `Jenkinsfile` at the root of a project.
- **Initial admin password** — a one-time secret Jenkins writes to a file on disk during install; it's on the filesystem, not in the install output, and is needed for the first web-UI login.

## Grafana

- **Dashboard** — a collection of panels that display related metrics. Example: an "API Health" dashboard with panels for latency, error rate, and request volume.
- **Panel** — a single visualization on a dashboard. Example: a time-series graph showing CPU usage over the last hour.
- **Data source** — the backend system Grafana queries. Example: connecting Grafana to a Prometheus server so it can pull metrics.
- **Query** — the expression Grafana sends to a data source to fetch data. Example: `rate(http_requests_total[5m])` in Prometheus.
- **Alert** — a rule that triggers a notification when a metric crosses a threshold. Example: alert when error rate exceeds 5% for 5 minutes.
- **Row** — a horizontal section on a dashboard that groups related panels. Example: a "Network" row containing latency and throughput panels.

## Prometheus

- **Metric** — a named time series identified by its name and optional key/value labels. Example: `http_requests_total` is a counter that increments on every HTTP request.
- **Series** — one stream of data points for a given metric + label combination. Example: `http_requests_total{method="POST"}` is a separate series from `http_requests_total{method="GET"}`.
- **Scrape** — Prometheus actively polls an HTTP endpoint that exposes metrics in a simple text format. Example: `prometheus.yml` tells Prometheus to fetch `/metrics` from each target every 15 seconds.
- **Scrape target** — a single endpoint Prometheus knows to poll. Example: `static_configs: - targets: ["localhost:9090"]` adds localhost:9090 as a target.
- **Exporter** — a small process that exposes metrics for another service or system. Example: the Node Exporter exposes host CPU, memory, and disk stats.
- **PromQL** — Prometheus's query language for selecting and aggregating time-series data. Example: `rate(http_requests_total[5m])` returns the per-second request rate over the last 5 minutes.
- **AlertManager** — receives alerts fired by Prometheus, handles deduplication, grouping, and routing. Example: a high-CPU alert fires to a Slack channel via AlertManager.
- **Job** — a logical name grouping scrape targets with shared configuration. Example: `job_name: "node"` collects all Node Exporter targets under one label.

## Kubernetes

- **Cluster** — a set of Nodes managed by Kubernetes; can be a local Minikube cluster or a cloud-based cluster with dozens of machines.
- **Deployment** — a controller that manages Pod replicas and handles rolling updates; defines the desired number of copies of an app and the image to use.
- **kubectl** — the command-line tool for talking to a Kubernetes cluster; used to deploy, inspect, and manage resources (e.g. `kubectl get pods`).
- **Minikube** — a tool that runs a single-node Kubernetes cluster locally inside a VM, ideal for learning and development.
- **Node** — a worker machine (physical or virtual) that runs Pods; the smallest unit of compute in a Kubernetes cluster.
- **Pod** — the smallest unit Kubernetes manages; it wraps one or more containers that share networking and storage.
- **Service** — a stable network endpoint that routes traffic to Pods; abstracts away the ephemeral nature of Pods so other components can reach them reliably.
- **Namespace** — a virtual cluster within a Kubernetes cluster that isolates resources; `kubectl get pods` only shows resources in the current namespace, so `--all-namespaces` is needed to see everything.
- **ClusterIP** — a Service type that exposes the service on a cluster-internal IP, reachable only from within the cluster.
- **NodePort** — a Service type that exposes the service on each Node's IP at a static port, making it reachable from outside the cluster without a cloud load balancer.
- **LoadBalancer** — a Service type that provisions an external cloud load balancer to route traffic to the service; on Minikube, `minikube service` is used instead.

## Concepts

- **Artifact** — a build output (binary, package, container image, or report) produced by one pipeline stage and consumed by the next; promoting an artifact means moving a specific version through dev → staging → prod.
- **CI/CD** — Continuous Integration (merging and testing code changes often) plus Continuous Delivery/Deployment (automatically getting those changes to production-ready or live states).
- **Pipeline** — an ordered sequence of automated stages (typically build → test → deploy) where each stage must pass before the next runs.
- **Gate** — a checkpoint in a pipeline that must succeed before the next stage runs; examples are test pass/fail, security scan thresholds, and manual approval steps.
- **Fail-fast** — stopping a pipeline the moment a stage fails so broken changes don't waste time or reach later stages; usually gated on exit codes.
- **Retry budget** — the number of times a pipeline stage re-runs a command after a transient failure before giving up; the failure-detection helper retries up to `RETRIES` (default 2) times and only exits non-zero after the budget is exhausted.
- **Structured log record** — a single line of machine-parseable output with key=value fields (e.g. `stage=deploy event=stage_failed attempt=1 exit_code=3`); written so a human or a monitoring tool can see exactly why a stage failed and how long it took.
- **Infrastructure as Code (IaC)** — managing servers, networks, and services through version-controlled definition files instead of manual clicks, so environments are reproducible.
- **Idempotence** — applying the same configuration repeatedly yields the same end state; a core property that makes IaC and automation safe to re-run.
- **Observability** — the ability to understand a system's internal state from its external outputs (metrics, logs, traces) without adding new instrumentation each time.
- **Monitoring** — collecting and tracking metrics, logs, and alerts so you know when something breaks; the practical, threshold-driven side of observability.
- **Metric** — a numeric measurement sampled over time (e.g. request latency, CPU usage) used to track system health and trigger alerts.
- **Port** — a numbered endpoint on a host that identifies a specific service, letting one machine run many networked programs at once.
- **Protocol** — an agreed set of rules for how machines exchange data (e.g. TCP, HTTP); both ends must speak the same one to communicate.
- **CLI** — command-line interface: interacting with a system by typing text commands rather than clicking a graphical desktop.
- **Kernel** — the core of an operating system that manages hardware, processes, and memory; the Linux kernel underpins most servers and containers.
- **Branch protection** — a repository-level rule that blocks direct pushes to a branch and requires status checks to pass before a pull request can be merged, enforcing the gate-before-merge pattern.
- **DORA metrics** — the four standard metrics for software delivery performance: deployment frequency, lead time for changes, change failure rate, and mean time to restore (MTTR).
- **Health dashboard** — a visual display of pipeline metrics and signal trends (build duration, queue time, test flake rate, deploy success) used to detect regressions in developer velocity.
- **Artifact immutability** — the principle that a build artifact should not change between environments; the same container image or binary runs in dev, staging, and production so failures are configuration problems, not binary-diff debugging.
- **DRY** — "Don't Repeat Yourself"; a principle that discourages duplicating logic, typically by extracting it into a reusable function or module instead of copy-pasting for every case.
- **Blue/green deployment** — a release strategy that keeps two identical production environments and switches traffic between them, enabling zero-downtime deploys and instant rollbacks.
- **Rolling restart** — a deployment strategy that replaces instances gradually, one at a time, so capacity is maintained throughout the update.
- **Golden signals** — the four key metrics for monitoring user-facing systems: latency, traffic (request rate), errors, and saturation (utilization of a constrained resource).
- **RED method** — a monitoring pattern that extracts three metrics per service — Rate (requests per second), Errors (error rate), and Duration (request latency) — so you can dashboard and alert on anything the user experiences.
- **Distributed tracing** — following a single request across the services it touches by propagating a trace ID, so per-hop latency and failures can be reconstructed even when each service's logs live on a different machine.
- **cloud-init** — a cross-distro standard for first-boot configuration; a VM reads a `user-data` file at first boot and applies the declarative setup (users, SSH keys, packages) before it is reachable, so provisioning is repeatable rather than hand-run.
- **Seed image (cloud-localds)** — the small ISO that carries a VM's cloud-init `user-data`/`meta-data` files; `cloud-localds seed.iso user-data` builds it and `virt-install --disk=…,seed.iso` attaches it as a second drive.
- **`qcow2`** — the copy-on-write disk image format used by QEMU/KVM; a base image stays immutable while each VM's overlay borrows from it, so many VMs reuse one download.
- **Error ratio** — the share of requests in a window that returned a non-2xx status; the "Errors" term of the RED method, computable straight from an access log without any dashboard.
- **Wall-clock latency** — the full elapsed time a client observes for a request (DNS, connect, transfer, and all), as reported by `curl -w '%{time_total}'`; distinct from server-side processing time.
- **Table-driven checks** — expressing a sequence of checks as data (a list of label/command pairs) and looping over it, so adding or changing a step edits one entry instead of another copy-pasted conditional block.


## GitLab CI

- **Pipeline trigger** — a Git event (push, tag, or merge request) that starts a pipeline; the manifest's `workflow.rules` block allows only those sources through and rejects manual and scheduled runs.
- **`$CI_PIPELINE_SOURCE`** — a predefined GitLab variable holding what started the pipeline (`merge_request_event`, `push`, and so on); the first gate in `workflow.rules`.
- **`$CI_COMMIT_TAG`** — the tag name when the pipeline was triggered by a tag push, and empty otherwise; used to make tag pipelines deploy automatically.
- **`$CI_COMMIT_SHORT_SHA`** — the abbreviated hash of the commit the pipeline was created for, so build artifacts stay traceable to an exact commit.
- **`$CI_COMMIT_REF_NAME`** — the branch or tag name the pipeline ran against (e.g. `main`); `rules` blocks use it to keep deploys off merge requests.

## GitHub Actions

- **Workflow** — a YAML file in `.github/workflows/` that defines a automated sequence of jobs triggered by events like pushes or pull requests.
- **Job** — a set of steps that run on the same runner; a workflow can have multiple jobs running in parallel or in sequence.
- **Step** — a single task within a job, such as checking out code, running a command, or uploading an artifact.
- **Secrets** — encrypted variables stored in the repo settings; used to pass tokens, passwords, and API keys to workflows without exposing them in the YAML.
- **Matrix build** — a strategy that runs the same job across multiple configurations (e.g. different OS versions or language versions) to verify compatibility.
- **Artifact** — a file or collection of files produced by a workflow run, such as a build output or test report; artifacts can be downloaded after the run completes.

## Networking

- **Overlay network** — a virtual network built on top of an existing network (underlay) that allows containers on different hosts to communicate as if they were on the same local network. Docker Swarm and Kubernetes CNI plugins create overlay networks automatically.
- **Underlay network** — the physical or virtual network that hosts connect to; the overlay tunnels traffic through the underlay. Example: the host's `eth0` network.
- **VXLAN** — Virtual Extensible LAN, the encapsulation protocol most overlay networks use; it wraps layer-2 Ethernet frames inside UDP packets to tunnel across the underlay. Docker overlay networks use VXLAN by default.
- **Service mesh** — an infrastructure layer that handles service-to-service communication (load balancing, retries, mTLS, observability) via sidecar proxies injected alongside each service instance. Examples: Istio, Linkerd.
- **mTLS (mutual TLS)** — both client and server authenticate each other via certificates; service meshes use mTLS to encrypt all inter-service traffic automatically.
- **Traffic splitting** — routing a percentage of requests to a different service version, e.g. sending 10% of traffic to a canary release.
- **Service discovery** — the mechanism by which services find each other's network locations; Kubernetes DNS gives each service a predictable hostname.

## Kubernetes (additional)

- **Resource requests** — the minimum CPU and memory a container needs; the scheduler uses this to pick a node with enough capacity.
- **Resource limits** — the maximum CPU and memory a container can use; exceeding the memory limit kills the container with an OOM error.
