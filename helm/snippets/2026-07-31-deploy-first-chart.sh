# last_verified: 2026-07-31 · helm n/a
# Install Helm, add repo, update, and deploy a test chart.

curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm repo add stable https://charts.helm.sh/stable
helm repo update
helm install my-nginx stable/nginx-ingress --namespace ingress --create-namespace
helm version