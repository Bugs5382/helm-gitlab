---
sidebar_position: 2
---

# 🏗️ Architecture

helm-gitlab is an umbrella chart. It renders its own datastore and supporting
resources, and pulls in a handful of subcharts as dependencies. Everything runs
in a single namespace.

## 🧩 Components

### 🦊 GitLab (official subchart)

GitLab Enterprise Edition is deployed via the upstream `gitlab` subchart. The
umbrella chart sets `global.psql`, `global.redis`, and the object-storage
connection details so GitLab talks to the in-cluster datastores below rather
than the bundled ones (the bundled PostgreSQL, Redis, and MinIO are disabled).

### 🐘 PostgreSQL 18 (hand-rolled)

Rather than an operator, the chart renders a **primary + standby** pair of
StatefulSets directly:

- **Primary** — a single-replica StatefulSet exposed by the `postgres-primary`
  ClusterIP Service, which is what GitLab's `global.psql.host` points at.
- **Standby** — `postgres.standby.replicas` pods that bootstrap from the
  primary via `pg_basebackup` in an init container, then follow it with
  **asynchronous streaming replication** (`primary_conninfo` in
  `postgresql.auto.conf`).
- **Failover is manual.** There is no automated leader election; promoting a
  standby is an operator action.
- Credentials (`gitlab` app role, `postgres` superuser, `replicator`) live in a
  Secret that is generated once and preserved across upgrades via the same
  `helm lookup` / `resource-policy: keep` pattern used for Valkey and SeaweedFS.
- Server config (`postgresql.conf`, `pg_hba.conf`) is mounted from a ConfigMap;
  replication is enabled with `wal_level=replica` and `hot_standby=on`.
- Primary and standbys are spread across nodes via pod anti-affinity
  (`postgres.antiAffinity`: `soft` preferred, or `hard` required).

### ⚡ Valkey

A Redis-compatible store, supplied as a **vendored chart** under `charts/valkey`
(a fork with a small helper rename patch). Its auth password is auto-generated
and kept stable across upgrades.

### 🪣 SeaweedFS (object storage)

Two SeaweedFS instances back GitLab's object storage:

- **Durable** — the primary S3-compatible store. A bucket is created per GitLab
  object-storage subsystem (artifacts, LFS, uploads, packages, registry, and so
  on) by a post-install/post-upgrade **bucket-init Job**.
- **Cache** (`seaweedfsCache`) — a second, **disposable** instance dedicated to
  the CI runner cache. It is `emptyDir`-backed so cache churn never touches
  durable storage; losing it only costs a cache rebuild.

Each instance has its own auto-generated S3 credentials so the two stores are
fully independent.

### 🚦 Traefik v3

Traefik is installed on an **isolated ingress class** (so it coexists with any
cluster-wide ingress controller). It fronts the GitLab web/registry HTTPS
endpoints and also carries TCP entrypoints for **Git SSH** (to gitlab-shell) and
the **toolbox SSH** sidecar via `IngressRouteTCP`.

### 🔐 TLS / cert-manager

The chart does **not** install a cert-manager controller. When
`certManager.enabled` is set, it renders `Certificate` resources that reference
a **cluster-wide `ClusterIssuer` you already run** (bring your own). With
cert-manager disabled, you supply TLS Secrets yourself.

### 🛠️ Toolbox SSH

An SSH sidecar injected into the GitLab toolbox pod lets admins reach the
toolbox container (for `rake` / rails console / maintenance) over an
`IngressRouteTCP` entrypoint. Auth is **SSH public key only** — you provide the
admin key via values.

### 📈 Monitoring

Prometheus `ServiceMonitor` emission is **per-environment** so clusters without
prometheus-operator install cleanly. SeaweedFS ships a `PrometheusRule` with
alerts that you can enable where prometheus-operator is present.

## 📚 Dependencies

| Chart | Version | Source |
|-------|---------|--------|
| gitlab | 9.11.6 | `https://charts.gitlab.io` |
| traefik | 32.1.1 | `https://traefik.github.io/charts` |
| valkey | 0.9.4 | vendored in `charts/` |
| seaweedfs | 4.34.0 | `https://seaweedfs.github.io/seaweedfs/helm` |
| seaweedfs (aliased `seaweedfsCache`) | 4.34.0 | same repo |

The chart targets Kubernetes **&ge; 1.28** and tracks GitLab app version 17.x.
