#!/usr/bin/env bash
# last_verified: 2026-10-20 · awx 24.6.1
# AWX quickstart: deploy AWX operator on Kubernetes and run first job template
# First-day notes — I'm learning AWX, so this script captures what worked and where I got stuck

# ---- Prerequisites I had to figure out ----
# - kubectl configured to a cluster (kind, minikube, or real cluster)
# - helm 3.x installed
# - At least 4GB RAM available for the cluster
# - StorageClass available for PVCs (default works on kind/minikube)

NAMESPACE="awx"
RELEASE_NAME="awx"
OPERATOR_VERSION="2.19.1"
AWX_VERSION="24.6.1"

echo "=== AWX Quickstart: Deploy Operator + AWX Instance ==="
echo "Namespace: $NAMESPACE"
echo "Operator version: $OPERATOR_VERSION"
echo "AWX version: $AWX_VERSION"
echo ""

# ---- Step 1: Add AWX Operator Helm repo ----
echo "--- Adding AWX Operator Helm repository ---"
helm repo add awx-operator https://ansible.github.io/awx-operator/ 2>/dev/null || true
helm repo update awx-operator
echo "Done."
echo ""

# ---- Step 2: Install AWX Operator ----
echo "--- Installing AWX Operator (version $OPERATOR_VERSION) ---"
helm upgrade --install awx-operator awx-operator/awx-operator \
  --namespace "$NAMESPACE" \
  --create-namespace \
  --version "$OPERATOR_VERSION" \
  --wait --timeout 5m
echo "Operator installed."
echo ""

# ---- Step 3: Create minimal AWX custom resource ----
# Got stuck here: the quickstart YAML from docs assumes you have a LoadBalancer.
# On kind/minikube, NodePort is easier. Also need to set admin password secret.
echo "--- Creating AWX custom resource (NodePort for local clusters) ---"
cat <<EOF | kubectl apply -f -
apiVersion: awx.ansible.com/v1beta1
kind: AWX
metadata:
  name: $RELEASE_NAME
  namespace: $NAMESPACE
spec:
  service_type: nodeport
  ingress_type: none
  admin_user: admin
  admin_email: admin@example.com
  admin_password_secret: awx-admin-password
  secret_key_secret: awx-secret-key
  postgres_configuration_secret: awx-postgres-config
  redis_configuration_secret: awx-redis-config
  projects_persistence: true
  projects_existing_claim: awx-projects-pvc
  web_replicas: 1
  task_replicas: 1
  web_resource_requirements:
    requests:
      cpu: 500m
      memory: 1Gi
    limits:
      cpu: 1000m
      memory: 2Gi
  task_resource_requirements:
    requests:
      cpu: 500m
      memory: 1Gi
    limits:
      cpu: 1000m
      memory: 2Gi
EOF
echo "AWX CR applied. Waiting for pods to become ready..."
echo ""

# ---- Step 4: Wait for AWX pods ----
echo "--- Waiting for AWX web and task pods (this takes a few minutes) ---"
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=awx,app.kubernetes.io/component=web -n "$NAMESPACE" --timeout=10m
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=awx,app.kubernetes.io/component=task -n "$NAMESPACE" --timeout=10m
echo "Pods are ready."
echo ""

# ---- Step 5: Get the NodePort URL ----
echo "--- Getting AWX URL ---"
NODE_PORT=$(kubectl get svc "$RELEASE_NAME"-service -n "$NAMESPACE" -o jsonpath='{.spec.ports[0].nodePort}')
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
AWX_URL="http://$NODE_IP:$NODE_PORT"
echo "AWX UI: $AWX_URL"
echo ""

# ---- Step 6: Get admin password ----
echo "--- Decoding admin password ---"
ADMIN_PASS=$(kubectl get secret awx-admin-password -n "$NAMESPACE" -o jsonpath='{.data.password}' | base64 -d)
echo "Username: admin"
echo "Password: $ADMIN_PASS"
echo ""

# ---- Step 7: Create a simple project and job template via CLI ----
# The UI works, but I wanted to script the "first job template" part too.
# Using awx.awx collection would be cleaner, but that needs a separate install.
# For now, just show the manual steps I'd do in the UI.
echo "=== Next manual steps in AWX UI ==="
echo "1. Open $AWX_URL and login with admin / $ADMIN_PASS"
echo "2. Create a Project:"
echo "   - Name: 'Hello World Project'"
echo "   - SCM Type: Git"
echo "   - SCM URL: https://github.com/ansible/awx-hello-world"
echo "   - SCM Branch: main"
echo "   - Click Save, then Sync (wait for success)"
echo ""
echo "3. Create an Inventory:"
echo "   - Name: 'Local Inventory'"
echo "   - Add a Host: 'localhost' (or your target managed node)"
echo "   - Add variable: ansible_connection=local"
echo ""
echo "4. Create a Credential:"
echo "   - Type: Machine"
echo "   - Username: (your user)"
echo "   - SSH Key: (paste your private key, or use password)"
echo ""
echo "5. Create a Job Template:"
echo "   - Name: 'Hello World Job'"
echo "   - Job Type: Run"
echo "   - Inventory: 'Local Inventory'"
echo "   - Project: 'Hello World Project'"
echo "   - Playbook: hello_world.yml"
echo "   - Credential: (select the one you created)"
echo "   - Limit: localhost"
echo "   - Click Save, then Launch"
echo ""
echo "=== Got stuck on ==="
echo "- 'Playbook stays in pending': check PVC space (kubectl get pvc -n $NAMESPACE) and supervisor logs (kubectl logs -n $NAMESPACE deploy/$RELEASE_NAME-task)"
echo "- 'Unable to login via HTTP': AWX enforces HTTPS; for HTTP-only, set SESSION_COOKIE_SECURE=False and CSRF_COOKIE_SECURE=False in extra_settings"
echo "- 'Error: provided hosts list is empty': host pattern in playbook must match inventory host name exactly (case-sensitive)"
echo "- 'Playbook not in dropdown': project sync must succeed; check awx-projects-pvc permissions (chown awx -R /var/lib/awx/projects/)"
echo ""
echo "=== What I'd try next ==="
echo "- Automate the UI steps using awx.awx collection (ansible-galaxy collection install awx.awx)"
echo "- Set up external PostgreSQL/Redis for durability"
echo "- Configure LDAP/OIDC authentication instead of local admin"
echo "- Add a proper Ingress with TLS for real deployments"