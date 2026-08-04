---
last_verified: 2026-08-04
tool_version: n/a
---

# Kubernetes quickstart — what tripped me up

> Following the official Kubernetes quickstart, here's what worked and where I got stuck.

## What I did

I started by setting up a local cluster with Minikube, then tried to deploy a simple web app. The quickstart walks you through creating a Deployment and exposing it as a Service, which sounds straightforward enough.

I ran `kubectl create deployment hello-node --image=k8s.gcr.io/echoserver:1.4` and it worked on the first try. The Deployment was created and the Pod started pulling the image. But then I hit my first wall — I couldn't figure out why I couldn't reach the app from my browser.

## What tripped me up

The first thing I missed was that a Deployment alone doesn't expose traffic outside the cluster. I had to create a Service to route traffic to the Pods. I ran `kubectl expose deployment hello-node --type=LoadBalancer --port=8080` and waited for the external IP to show up. On Minikube, I needed to run `minikube service hello-node` to get the URL instead of waiting for a real cloud LoadBalancer.

The second thing that caught me out was namespace confusion. I kept running `kubectl get pods` and seeing nothing, even though I knew I had a Deployment running. It turned out I had accidentally created the Deployment in a different namespace. Running `kubectl get pods --all-namespaces` revealed it immediately.

The third stumbling block was understanding the difference between `kubectl run` and `kubectl create deployment`. The quickstart uses `kubectl create deployment`, but a lot of older tutorials still reference `kubectl run` which has different behavior — it can create a Deployment or a Job depending on the flags, and the semantics have changed across Kubernetes versions.

## What I'd try next

I want to dig into how Services actually route traffic to Pods, especially the difference between ClusterIP, NodePort, and LoadBalancer types. I also plan to try rolling updates with a Deployment so I can see how Kubernetes handles version transitions.