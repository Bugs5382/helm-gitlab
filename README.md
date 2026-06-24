# 🦊 helm-gitlab

A self-hosted, **bring-your-own-datastores** GitLab Helm chart (PostgreSQL HA, Valkey, SeaweedFS, Traefik), genericized for public use.

> 📦 This repository ships **source you deploy yourself** — there is no published Docker image and no packaged/registry'd chart. You build your own images and `helm install ./`.

## ✨ What's inside

- 🐘 **PostgreSQL 18** — hand-rolled primary + standby with async streaming replication and manual failover.
- ⚡ **Valkey** — Redis-compatible store (upstream chart).
- 🪣 **SeaweedFS** — S3-compatible object storage (durable + a disposable runner-cache instance).
- 🚦 **Traefik v3** — on an isolated ingress class.

GitLab itself is deployed via the official GitLab subchart, configured to consume those datastores.

## 🚀 Quick start

```bash
helm repo add gitlab    https://charts.gitlab.io
helm repo add traefik   https://traefik.github.io/charts
helm repo add valkey    https://valkey.io/valkey-helm
helm repo add seaweedfs https://seaweedfs.github.io/seaweedfs/helm
helm repo update
helm dependency build .
helm upgrade --install gitlab . -n gitlab --create-namespace -f my-values.yaml
```

See the [installation guide](https://bugs5382.github.io/helm-gitlab/docs/installation) for required values and image-build steps.

## 📚 Documentation

Full docs: **https://bugs5382.github.io/helm-gitlab/**

- [Introduction](https://bugs5382.github.io/helm-gitlab/docs/intro)
- [Architecture](https://bugs5382.github.io/helm-gitlab/docs/architecture)
- [Prerequisites](https://bugs5382.github.io/helm-gitlab/docs/prerequisites)
- [Installation](https://bugs5382.github.io/helm-gitlab/docs/installation)
- [Configuration](https://bugs5382.github.io/helm-gitlab/docs/configuration)

## 📄 License

Apache-2.0, Copyright 2026 Shane.
