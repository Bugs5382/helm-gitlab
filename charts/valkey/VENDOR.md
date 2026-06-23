# Vendored fork: `valkey-helm` 0.9.4

This directory contains a vendored copy of the `valkey-helm` Helm
chart, version **0.9.4**, sourced from
<https://valkey.io/valkey-helm/>.

It is **not** managed via the parent `Chart.yaml` dependencies block.
Helm picks subcharts up by their presence in `charts/`, so listing it
in dependencies would only invite `helm dependency update` to clobber
our patch on the next refresh.

## Why we forked

`valkey-helm/templates/_helpers.tpl` defines a global Helm template
named `common.image`. Our umbrella also depends on `seaweedfs`, which
defines its **own** `common.image` with an incompatible call signature.
Helm registers named templates per release globally, so when both
charts ship the same name the second definition silently shadows the
first and one of the two charts breaks at render time.

The visible failure was:

    Error: helm-gitlab/charts/valkey/templates/tests/auth.yaml:100:16
      executing "valkey.image" at <include "common.image" (dict ...)>:
      error calling include:
    helm-gitlab/charts/seaweedfs/templates/_helpers.tpl:88:36
      executing "common.image" at <.Values.image.registry>:
      nil pointer evaluating interface {}.image

`helm template --show-only` confirmed the failure isn't limited to
the test template — the StatefulSet path fails the same way once
rendering of the test template has poisoned the well.

## What we changed

Inside `templates/_helpers.tpl`, the helper `common.image` was renamed
to `valkey.common.image`. Both internal callers (`valkey.image` and
`valkey.metrics.exporter.image`) were updated to the new name. The
chart's `common.image` body and signature are otherwise identical to
upstream 0.9.4.

That single rename eliminates the collision: this chart now uses a
chart-namespaced helper, while `seaweedfs` continues to use its own
unrelated `common.image`. No other files in this directory differ
from the upstream 0.9.4 release.

## Upstream bug

Reported / to-be-reported: see
`docs/upstream-bug-reports/valkey-helm-0.9.4-helper-collision.md` at
the repo root. The recommended upstream fix is to namespace internal
helpers (e.g. `valkey.common.image`), which is what this fork does.

## How to upgrade

When `valkey-helm` ships a new release:

1. Re-extract the new tarball into `charts/valkey/` (replacing this
   directory wholesale).
2. Re-apply the helper rename: in `charts/valkey/templates/_helpers.tpl`,
   change every reference to `common.image` (both the `define` and
   the `include` call sites) so the name is `valkey.common.image`.
3. Re-render with `helm install --dry-run=client` — should succeed.
4. Update this file's "version" header.

If upstream eventually namespaces their helper, drop the fork and
re-add `valkey` to the parent `Chart.yaml` dependencies.
