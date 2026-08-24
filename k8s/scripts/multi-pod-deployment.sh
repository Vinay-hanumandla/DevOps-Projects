#!/usr/bin/env bash
# last_verified: 2026-08-24 · k8s n/a

# multi-pod-deployment.sh — deploy a multi-tier app with kubectl
# This script creates backend and frontend deployments, then exposes each
# with a ClusterIP service. It uses kubectl's imperative commands so I can
# practice the CLI workflow without writing raw YAML.

set -o pipefail

if ! command -v kubectl >/dev/null 2>&1; then
    echo "Error: kubectl is not installed or not in PATH" >&2
    exit 1
fi

if ! kubectl cluster-info >/dev/null 2>&1; then
    echo "Error: cannot reach a Kubernetes cluster" >&2
    exit 1
fi

NAMESPACE="${1:-default}"

echo "Deploying multi-pod app to namespace: $NAMESPACE"

if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
    kubectl create namespace "$NAMESPACE"
    if [ $? -ne 0 ]; then
        echo "Error: failed to create namespace $NAMESPACE" >&2
        exit 1
    fi
fi

if ! kubectl get deployment backend --namespace="$NAMESPACE" >/dev/null 2>&1; then
    kubectl create deployment backend --image=nginx --replicas=2 \
        --namespace="$NAMESPACE"
    if [ $? -ne 0 ]; then
        echo "Error: failed to create backend deployment" >&2
        exit 1
    fi
else
    echo "backend deployment already exists in $NAMESPACE — skipping"
fi

if ! kubectl get deployment frontend --namespace="$NAMESPACE" >/dev/null 2>&1; then
    kubectl create deployment frontend --image=nginx --replicas=3 \
        --namespace="$NAMESPACE"
    if [ $? -ne 0 ]; then
        echo "Error: failed to create frontend deployment" >&2
        exit 1
    fi
else
    echo "frontend deployment already exists in $NAMESPACE — skipping"
fi

if ! kubectl get service backend --namespace="$NAMESPACE" >/dev/null 2>&1; then
    kubectl expose deployment backend --port=80 --target-port=80 \
        --namespace="$NAMESPACE"
    if [ $? -ne 0 ]; then
        echo "Error: failed to expose backend service" >&2
        exit 1
    fi
else
    echo "backend service already exists in $NAMESPACE — skipping"
fi

if ! kubectl get service frontend --namespace="$NAMESPACE" >/dev/null 2>&1; then
    kubectl expose deployment frontend --port=80 --target-port=80 \
        --namespace="$NAMESPACE"
    if [ $? -ne 0 ]; then
        echo "Error: failed to expose frontend service" >&2
        exit 1
    fi
else
    echo "frontend service already exists in $NAMESPACE — skipping"
fi

echo ""
echo "Waiting for pods to become Ready..."
kubectl wait --for=condition=Ready pods --all --timeout=120s \
    --namespace="$NAMESPACE" 2>/dev/null || true

echo ""
echo "Pod status:"
kubectl get pods --namespace="$NAMESPACE"

echo ""
echo "Service status:"
kubectl get services --namespace="$NAMESPACE"

echo ""
echo "Done. Clean up with: kubectl delete namespace $NAMESPACE"
