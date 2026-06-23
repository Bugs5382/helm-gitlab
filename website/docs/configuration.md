---
sidebar_position: 5
---

# ⚙️ Configuration

All settings live in `values.yaml`, which ships **env-agnostic defaults**. Keep
per-environment overrides (hostnames, storage class, secrets) in a separate
values file and pass it with `-f`. Generated secrets (Valkey password, SeaweedFS
S3 credentials, the PostgreSQL app password) are created once and preserved
across upgrades via `helm lookup` / `resource-policy: keep`.

## 🔴 Required values

The chart refuses to render until these are set:

| Value | Description |
|-------|-------------|
| `image.registry` | Registry holding the images you built (e.g. `registry.example.com`). |
| `hostnames.gitlab` | GitLab web hostname. |
| `hostnames.registry` | Container registry hostname. |
| `hostnames.kas` | GitLab Agent Server (KAS) hostname. |
| `hostnames.ssh` | Git SSH hostname (may equal `hostnames.gitlab`). |
| `storageClass` | A ReadWriteOnce StorageClass name. |
| `ingressClassName` | The ingress class Traefik runs on. |
| `toolboxSsh.publicKey` | Admin SSH public key — required when `toolboxSsh.enabled` (the default). |

## 🐘 PostgreSQL — `postgres`

The hand-rolled primary + standby pair.

| Value | Default | Description |
|-------|---------|-------------|
| `postgres.enabled` | `true` | Render the in-cluster PostgreSQL. |
| `postgres.standby.replicas` | `1` | Number of async streaming standbys. |
| `postgres.antiAffinity` | `soft` | `soft` (preferred) or `hard` (required) host spread. |
| `postgres.storage.size` | `10Gi` | PVC size per pod (raise for production). |
| `postgres.storage.storageClass` | `""` | Defaults to the top-level `storageClass`. |
| `postgres.resources` | requests 250m/512Mi | CPU/memory requests and limits. |
| `postgres.parameters.*` | conservative | `max_connections`, `shared_buffers`, etc. |
| `postgres.secretName` | `gitlab-postgres-app` | Credentials Secret name. |

:::note
Failover is **manual** — promoting a standby is an operator action. Replication
is asynchronous.
:::

## 🪣 Object storage — `objectStorage` / `seaweedfs` / `seaweedfsCache`

| Value | Default | Description |
|-------|---------|-------------|
| `objectStorage.buckets.*` | per subsystem | Bucket name per GitLab object-storage subsystem (artifacts, LFS, uploads, packages, registry, …). |
| `objectStorage.bucketInit.enabled` | `true` | Run the post-install/upgrade Job that creates the buckets. |
| `seaweedfs.enabled` | `true` | The durable S3 store. |
| `seaweedfsCache.enabled` | `true` | The disposable, `emptyDir`-backed runner-cache store. |
| `seaweedfsAuth` / `seaweedfsCacheAuth` | auto | Auto-generated S3 credentials (kept across upgrades). |

## ⚡ Valkey — `valkey` / `valkeyAuth`

| Value | Default | Description |
|-------|---------|-------------|
| `valkey.enabled` | `true` | The Redis-compatible store (vendored chart). |
| `valkeyAuth.secretName` | `valkey-auth` | Auto-generated auth Secret. |

## 🚦 Ingress & networking — `traefik`, `gitssh`, `ingressClassName`

| Value | Default | Description |
|-------|---------|-------------|
| `traefik.enabled` | `true` | Install Traefik v3 on its own ingress class. |
| `ingressClassName` | `""` (required) | The class Traefik serves. |
| `gitssh.enabled` | `true` | Expose Git SSH via an `IngressRouteTCP` to gitlab-shell. |
| `clusterDomain` / `global.dnsDomain` | `cluster.local` | Cluster DNS suffix. |

## 🔐 TLS — `certManager`

| Value | Default | Description |
|-------|---------|-------------|
| `certManager.enabled` | `false` | Render `Certificate` resources for a cluster-wide `ClusterIssuer`. |
| `certManager.issuerName` | `letsencrypt` | Name of the existing `ClusterIssuer`. |
| `certManager.email` | `""` | Required when enabled. |

When disabled, provide TLS Secrets yourself.

## 🛠️ Toolbox SSH — `toolboxSsh`

| Value | Default | Description |
|-------|---------|-------------|
| `toolboxSsh.enabled` | `true` | Inject the SSH sidecar into the toolbox pod. |
| `toolboxSsh.publicKey` | `""` (required) | Admin SSH public key (key auth only). |
| `toolboxSsh.username` | `admin` | SSH username. |

## 📈 Monitoring — `seaweedfsAlerts` and subchart ServiceMonitors

ServiceMonitor / PrometheusRule emission is **per-environment** so the chart
installs cleanly without prometheus-operator. Enable the SeaweedFS alert rules
(`seaweedfsAlerts`) and subchart ServiceMonitors only where prometheus-operator
is present.

## 🏷️ Other

| Value | Default | Description |
|-------|---------|-------------|
| `runner.jobNamespace` | `gitlab-runner-job` | Namespace for CI build pods. |
| `releaseNamespace` | `gitlab` | Used in NOTES and templated references; match your install namespace. |

For the full set of tunables and inline guidance, read `values.yaml` directly —
every block is documented in place.
