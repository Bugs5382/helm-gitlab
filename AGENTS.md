# AGENTS.md - helm-gitlab

Guide for AI agents working in this repository. Pair with `CLAUDE.md` (the working agreement and
hook-enforced rules). Keep this file current when the build, layout, or public API changes.

## What this is

A self-hosted, **bring-your-own-datastores** GitLab Helm chart for Kubernetes. It deploys the
official GitLab subchart wired to first-class, in-cluster datastores it renders itself —
hand-rolled **PostgreSQL 18** (primary + standby, async streaming replication, manual failover),
**Valkey** (vendored), **SeaweedFS** (durable + a disposable runner-cache instance), and
**Traefik v3** on an isolated ingress class.

Two things to understand before changing it:

1. It ships **source you deploy yourself** — there is no published Docker image and no packaged
   chart. Consumers build their own images and run `helm install ./` from a fork/checkout.
2. PostgreSQL is hand-rolled (no operator). Streaming replication and the `postgres` superuser are
   load-bearing; do not confuse `pg_basebackup` replication with a backup feature.

## Using helm-gitlab

Consumed by **forking** the repo, not by `helm repo add`. A consumer must:

- Set the required values or the chart refuses to render: `image.registry`,
  `hostnames.{gitlab,registry,kas,ssh}`, `storageClass`, `ingressClassName`, and
  `toolboxSsh.publicKey` (when `toolboxSsh.enabled`).
- Build and push the images under `images/` to their `image.registry`.
- Provide their own datastores' tuning via a separate `values-<env>.yaml` (don't edit `values.yaml`,
  which holds env-agnostic defaults). Generated secrets are preserved across upgrades via
  `helm lookup` / `resource-policy: keep`.

There are **no maintenance CronJobs and no in-cluster pgBackRest backup** (removed in 0.1.0). The
`postgres` image is still `postgres-pgbackrest:18` pending an image-version rule — don't reintroduce
the backup feature.

## Layout

- `Chart.yaml` / `Chart.lock` - chart metadata + pinned dependencies (gitlab, traefik, seaweedfs;
  valkey is vendored).
- `values.yaml` - env-agnostic defaults, documented inline. Per-env overlays are separate `-f` files.
- `templates/` - the rendered resources: `postgres-*` (primary/standby/config/secret), SeaweedFS
  bucket-init Jobs + PrometheusRule, `certificates.yaml`, `toolbox-ssh.yaml`, ingress routes,
  secrets, and `_helpers.tpl`.
- `charts/valkey/` - vendored Valkey fork (no `repository:` in Chart.yaml; do not `helm dep update`
  it away). See its `VENDOR.md`.
- `images/` - Dockerfiles for the images you build and push.
- `website/` - the documentation site (Docusaurus). See `website/AGENTS.md`.
- `.github/` - workflows (CI, release-drafter, label/PR checks, docs publish), issue/PR templates.
- `Taskfile.yml` - `task license` runs the golic Apache-header check.

## Build, test, lint

There is no unit-test suite; correctness is lint + a full template render. Run dependencies first:

- Deps: `helm repo add gitlab https://charts.gitlab.io && helm repo add traefik https://traefik.github.io/charts && helm repo add seaweedfs https://seaweedfs.github.io/seaweedfs/helm && helm dependency build .`
- Lint: `helm lint .`
- "Test" (render): `helm template gitlab . -f values-<env>.yaml --api-versions monitoring.coreos.com/v1 --api-versions autoscaling/v2` (the api-versions are required or capability-gated templates short-circuit and the render is vacuous).
- License headers: `task license` (golic, dry-run; `task license:fix` injects). Headers go on
  `*.yaml/yml/sh/tpl/ts` and `Dockerfile`; `website/`, `charts/`, `templates/`, and `*.md` are excluded.
- Workflows: validated by the `Actionlint` PR check — keep job ids plain identifiers (emoji/display
  text go in `name:`, never the job key).

## Conventions and gotchas

- See `CLAUDE.md` for the branch/commit/PR rules; they are enforced by the git hooks in
  `.claude/hooks` (run `bash .claude/hooks/install.sh` once per clone).
- **Issue-first.** Every PR body must reference an issue (`Closes #N`) — CI fails otherwise. PR/issue
  titles are Conventional Commits; the autolabeler derives the category label from the title.
- **No AI tells or emoji** in commits, PR/issue titles+bodies, comments, or source. Emoji are welcome
  in docs-site content only (see `website/AGENTS.md`).
- **Pre-1.0 / source-only:** no published chart or image; the maintainer publishes a GitHub Release
  by hand, which creates the `vX.Y.Z` tag. Nothing tags automatically.
- The docs site builds/publishes **only on release tags**, never on merge to `main`.
