---
sidebar_position: 1
---

# 🦊 Introduction

**helm-gitlab** is a self-hosted, **bring-your-own-datastores** GitLab Helm
chart for Kubernetes. Instead of leaning on the upstream GitLab chart's bundled
(and largely not-for-production) PostgreSQL, Redis, and MinIO, it wires GitLab
up to first-class in-cluster datastores that you operate yourself:

- 🐘 **PostgreSQL 18** — a hand-rolled primary + standby pair with asynchronous
  streaming replication and manual failover.
- ⚡ **Valkey** — a Redis-compatible store via a vendored chart.
- 🪣 **SeaweedFS** — S3-compatible object storage (two instances: one durable,
  one disposable for the CI runner cache).
- 🚦 **Traefik v3** — on an isolated ingress class so it never collides with a
  cluster-wide ingress controller.

GitLab itself is deployed through the **official GitLab subchart**, configured
to consume those datastores.

## 📦 Distribution model

This repository ships **source you deploy yourself**. There is:

- **no published Docker image**, and
- **no packaged / registry'd Helm chart**.

You build your own container images (see the `images/` directory) and run
`helm install ./` against a checkout. This keeps the supply chain entirely in
your hands — nothing here pulls a prebuilt artifact you didn't produce.

## 🤔 Is this for you?

Use helm-gitlab if you want GitLab on Kubernetes with **production-grade,
in-cluster backing services that you control** — distinct PostgreSQL replicas,
your own object storage, your own ingress — rather than the convenience
single-pod datastores the upstream chart bundles for evaluation.

If you already run managed PostgreSQL / Redis / object storage (RDS,
ElastiCache, S3), the upstream GitLab chart pointed at those externally may suit
you better.

## 👉 Next steps

- [Architecture](./architecture) — what each component is and how it fits.
- [Prerequisites](./prerequisites) — what your cluster needs first.
- [Installation](./installation) — repo setup, dependencies, and `helm install`.
- [Configuration](./configuration) — required values and the main tunables.
