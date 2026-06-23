---
sidebar_position: 3
---

# ✅ Prerequisites

Before installing helm-gitlab, make sure your cluster and tooling are ready.

## 🧰 Tooling

- **Helm 3+** on your workstation.
- **kubectl** configured against the target cluster.
- A container image build tool (Docker, Buildah, …) — this chart ships **source
  only**, so you build the images it references yourself (see `images/`).

## ☸️ Cluster

- **Kubernetes &ge; 1.28.**
- A **ReadWriteOnce StorageClass** for the PostgreSQL and SeaweedFS persistent
  volumes. Set its name in `storageClass`.
- An **ingress class name** (`ingressClassName`). The chart installs Traefik v3
  on its own isolated class; point this at that class.
- **DNS** for your GitLab, registry, KAS, and SSH hostnames, resolving to the
  ingress load balancer.

## 🐳 Container registry

- A registry you can **push to and pull from** (`image.registry`), e.g.
  `registry.example.com` or `docker.io/youruser`.
- Build and push the images under `images/` (including the PostgreSQL image) to
  that registry before installing.

## 🔐 Optional

- **cert-manager** — if you want the chart to issue TLS automatically, run a
  cluster-wide cert-manager controller and a `ClusterIssuer`, then set
  `certManager.enabled=true` and `certManager.issuerName`. Otherwise, supply TLS
  Secrets yourself.
- **prometheus-operator** — required only if you enable `ServiceMonitor` /
  `PrometheusRule` emission. The chart installs cleanly without it.

Once these are in place, head to [Installation](./installation).
