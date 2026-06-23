---
sidebar_position: 4
---

# 🚀 Installation

helm-gitlab is installed from a checkout of this repository — there is no
published chart to `helm repo add`.

## 1️⃣ Add the dependency repos

The umbrella chart depends on the GitLab, Traefik, and SeaweedFS charts (Valkey
is vendored in `charts/`). Add their repos so Helm can resolve them:

```bash
helm repo add gitlab    https://charts.gitlab.io
helm repo add traefik   https://traefik.github.io/charts
helm repo add seaweedfs https://seaweedfs.github.io/seaweedfs/helm
helm repo update
```

## 2️⃣ Build the chart dependencies

From the chart root:

```bash
helm dependency build .
```

This pulls the pinned dependency versions (per `Chart.lock`) into `charts/`.

## 3️⃣ Build and push your images

This repo ships source only. Build the images under `images/` and push them to
your registry, then reference that registry via `image.registry`.

## 4️⃣ Provide values

At minimum you must set the [required values](./configuration).
Put environment-specific settings in your own values file (for example
`my-values.yaml`) rather than editing `values.yaml`:

```yaml
image:
  registry: registry.example.com
hostnames:
  gitlab:   gitlab.example.com
  registry: registry.example.com
  kas:      kas.example.com
  ssh:      gitlab-ssh.example.com
storageClass: your-rwo-storageclass
ingressClassName: your-ingress-class
toolboxSsh:
  publicKey: "ssh-ed25519 AAAA... you@example.com"
```

## 5️⃣ Install

```bash
helm upgrade --install gitlab . \
  -n gitlab --create-namespace \
  -f my-values.yaml
```

## 6️⃣ Verify

```bash
kubectl -n gitlab get pods
```

The PostgreSQL primary and standby StatefulSets should become Ready, the
SeaweedFS bucket-init Job should complete, and the GitLab webservice should come
up behind Traefik at your configured hostname.

:::tip
Render the chart without applying it to sanity-check your values:

```bash
helm template gitlab . -f my-values.yaml \
  --api-versions monitoring.coreos.com/v1 \
  --api-versions autoscaling/v2 > /dev/null
```
:::
