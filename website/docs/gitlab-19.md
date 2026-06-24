---
sidebar_position: 7
---

# 🎯 Targeting the latest GitLab (19.x)

helm-gitlab is designed for the **latest GitLab release**. GitLab 19 ships as the
official `gitlab/gitlab` chart **10.x** (chart `10.0.x` = GitLab `v19.0.x`,
`10.1.x` = `v19.1.x`; the older `9.11.x` line was `v18.11.x`). Moving to chart
10.x carries a few breaking changes that shape how this chart is built. This page
captures the end-state requirements — not an incremental upgrade procedure.

## 🚪 Gateway API + envoy-gateway are ON by default — keep them off for Ingress

GitLab 19 flips `global.gatewayApi.{enabled, installEnvoy, configureCertmanager}`
to `true`. For a Traefik/Ingress-based deployment that's a problem:

- The bundled **`envoy-gateway`** subchart (an alias of `gateway-helm`) renders
  **cluster-scoped** `ClusterRole`/`ClusterRoleBinding` resources (controller +
  certgen). Any least-privilege, namespace-scoped install breaks on these.
- The **`certmanager-issuer`** subchart's ConfigMap then **fails the render**,
  demanding a `certmanager-issuer.email`.

Disable Gateway API:

```yaml
global:
  gatewayApi:
    enabled: false
    installEnvoy: false
    configureCertmanager: false
```

⚠️ **Placement gotcha.** The envoy-gateway dependency is gated by
`condition: global.gatewayApi.installEnvoy`. A Helm dependency `condition:`
resolves globals against the **top-level** `global:`, not a `gitlab.global:` you
set on a wrapping umbrella. `configureCertmanager`, by contrast, is read at
**render time** (so it propagates via `gitlab.global` too). When wrapping the
GitLab chart, set `installEnvoy` at the true top-level `global:` or the subchart
still installs. This chart defaults Gateway API **off** and exposes it as an
opt-in.

## 🪣 Bundled object storage is gone — external storage is mandatory (including backups)

Chart 10.x **removed the bundled `postgresql` and `redis` subcharts** and the
bundled MinIO object storage. `gitlab.checkConfig` now **hard-fails the render**
unless object storage is configured. The piece that's easy to miss: **backups**.

- `gitlab.toolbox.backups.objectStorage.config.secret` must point at a Secret
  holding an **s3cmd `.s3cfg`** (default key `config`). Without it the render
  fails with *"Backup Object Storage: the chart provides no longer bundled object
  storage solution…"*.
- The registry needs `registry.storage.secret`; the consolidated
  `global.appConfig.object_store` block covers the rest (LFS, artifacts, uploads,
  …). Pages inherits it when consolidated storage is on.
- Use `global.psql` (external Postgres) and `global.redis` (external
  Redis/Valkey) — the bundled ones no longer exist. The old
  `postgresql.install: false` / `redis.install: false` keys are now dead no-ops
  (10.x ships **no `values.schema.json`**, so they're tolerated rather than
  rejected).

Generate the backup `.s3cfg` from the **same** credentials and endpoint as the
rest of object storage: path-style + HTTP for an in-cluster S3 like SeaweedFS;
region + HTTPS for AWS S3.

## 🤖 `ai-gateway` subchart added

Chart 10.x adds an `ai-gateway` subchart. It defaults to `install: false` — no
action needed, just know it exists.

## 📌 Keep StatefulSet volumeClaimTemplates labels stable

This is a general chart-design rule that bites hard at GitLab 19. If a chart
hand-rolls any StatefulSet (e.g. a bundled database), do **not** put volatile
labels — `helm.sh/chart` (the chart version) or `app.kubernetes.io/version` (the
appVersion) — in `spec.volumeClaimTemplates[].metadata.labels`. The VCT is
**immutable**, so any chart-version or appVersion bump then fails every
`helm upgrade` with *"updates to statefulset spec … are forbidden"*. Use a stable,
selector-style label subset there.

## 🧭 Net design posture

For a clean, GitLab-19-native chart:

- Default Gateway API **off**, opt-in.
- **Require and wire external object storage**, including a backup s3cmd secret.
- Assume **no bundled PostgreSQL or Redis** — bring your own datastores.
- Keep **StatefulSet VCT labels stable** so version bumps never block upgrades.
