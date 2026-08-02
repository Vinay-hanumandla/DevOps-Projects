#!/bin/bash
# last_verified: 2026-08-02 · k8s n/a

curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube
sudo mv minikube /usr/local/bin/
minikube start
kubectl version --client