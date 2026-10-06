# last_verified: 2026-10-06 · grafana n/a

# Custom Grafana image: plugins pre-installed at build time and a default
# datasource provisioned into the image, so every environment starts from the
# same baked build instead of downloading plugins on first boot or registering
# the datasource through the UI.
#
# Purpose: ship a fixed plugin set and a known datasource as an immutable image
# artifact, decoupled from whatever a live container happens to pull at startup.
#
# When to use: teams that standardize on a small set of panel/datasource
# plugins and a single default datasource, and who want both to be present
# before the container serves its first request.
#
# Prerequisites: a registry to push to; the plugin IDs to bake in.
#
# Build args:
#   GRAFANA_VERSION  base image tag to build from, e.g. `11.5.0` or `main`.
#   GRAFANA_PLUGINS  comma-separated plugin IDs, e.g. `grafana-piechart-panel`.
#                    Leave unset to skip plugin installation entirely.
#
# Steps:
#   1. docker build --build-arg GRAFANA_VERSION=<tag> \
#         --build-arg GRAFANA_PLUGINS=grafana-piechart-panel \
#         -t grafana-custom:<tag> .
#   2. docker push grafana-custom:<tag>
#   3. Point the deployment at grafana-custom:<tag>; the datasource below is
#      loaded on startup and the plugins are already on disk.
#
# Verify: `docker run --rm grafana-custom:<tag> grafana-cli plugins ls` lists
# the baked-in plugins; the provisioned Prometheus datasource appears before
# first login under Configuration -> Data Sources.

# Pin the base through a build arg instead of hardcoding a tag inline, so the
# same Dockerfile is reused across release lines without a source edit.
ARG GRAFANA_VERSION
FROM grafana/grafana:${GRAFANA_VERSION}

ARG GRAFANA_PLUGINS=""
ARG GRAFANA_PROVISIONING_DIR=/etc/grafana/provisioning

# grafana-cli needs to write to /var/lib/grafana/plugins, so run the install as
# root during the build; the final image drops back to the unprivileged grafana
# user (UID 104 in the base image) before runtime. A comma-separated plugin list
# is split into separate arguments so grafana-cli sees one ID per positional.
USER root
RUN if [ -n "${GRAFANA_PLUGINS}" ]; then \
        grafana-cli plugins install $(echo "${GRAFANA_PLUGINS}" | tr ',' ' '); \
    fi

# Provision a default datasource. Grafana loads every file under
# provisioning/datasources/ on startup, so baking it in makes the target appear
# before first login instead of having to add it through the UI.
RUN mkdir -p "${GRAFANA_PROVISIONING_DIR}/datasources" && \
    cat > "${GRAFANA_PROVISIONING_DIR}/datasources/datasources.yaml" <<'EOF'
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
EOF

# Revert to the base image's default unprivileged user. The build ran as root
# only to write provision files into /etc and install plugins into /var/lib.
USER 104
