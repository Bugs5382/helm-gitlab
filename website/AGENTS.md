# AGENTS.md — docs site (`website/`)

Guide for AI agents working on the **documentation site**. Pair with the repo-root
`AGENTS.md` and `CLAUDE.md` for the repo-wide working agreement and hook-enforced rules.
Keep this file current when the site's layout, theme, or deploy model changes.

## What this is

A [Docusaurus](https://docusaurus.io/) site published to GitHub Pages at
`https://bugs5382.github.io/helm-gitlab/`. It documents the helm-gitlab chart — it is not the
chart itself (the chart lives at the repo root).

## Preview, validate, build

Run these from `website/` (Node ≥ 20, npm):

- **Preview:** `npm start` — dev server with hot reload (`http://localhost:3000/helm-gitlab/`).
  Use this to see changes; it is the normal way to work.
- **Validate:** `npm run typecheck` — runs `tsc`. Use this to check `.tsx`/config changes.
- **Build:** `npm run build` — **DO NOT run for routine edits.** The build + publish is
  **tag-gated**: the `Docs Publish` workflow builds and deploys only on `vX.Y.Z` release tags,
  never on a merge to `main`. Only build when cutting a release.

## Layout

- `docs/` — the documentation pages (Markdown). The sidebar is **auto-generated** from the
  folder; order pages with a `sidebar_position` frontmatter key.
- `src/pages/index.tsx` — the homepage (hero with the fork → tailor → deploy terminal).
- `src/components/HomepageFeatures/` — the stack cards + the "Start here" docs map below the hero.
- `src/css/custom.css` — theme: fonts (Bricolage Grotesque + IBM Plex Sans/Mono), the GitLab
  color palette, hero/footer styling. Most look-and-feel lives here via CSS variables.
- `docusaurus.config.ts` — site config: navbar, footer (incl. the disclaimer), font `stylesheets`,
  favicon, Pages URL. **Config changes need a dev-server restart** (they do not hot-reload).
- `static/img/` — assets, including `gitlab-logo.png` (navbar logo + favicon).

## Adding a docs page

Drop a `.md` into `docs/` with frontmatter, e.g.:

```md
---
sidebar_position: 6
---

# 🧭 My page
```

It appears in the sidebar automatically. **Use tasteful emoji** in headings/callouts — that is the
site's voice. **Do NOT** use the `## Heading {#custom-id}` explicit-anchor syntax: it fails MDX 3
compilation ("Could not parse expression with acorn"). Rely on the auto-generated slug instead.

## Conventions and gotchas

- **Tag-gated publish** — see above. Preview with `npm start`; never `npm run build` for routine work.
- **Emoji** belong in docs/site content only. Commit messages and PR/issue titles + bodies stay
  **emoji-free and AI-tell-free** (enforced by CI; see `CLAUDE.md`).
- **No license headers** in `website/` files — golic excludes this tree (`.licignore`).
- **GitLab branding is intentional but UNOFFICIAL.** If you touch branding, keep the footer
  disclaimer: not affiliated with GitLab Inc.; "GitLab" and the logo are trademarks of GitLab Inc.,
  used for identification only.
- **Pages deploy setup (one-time)** — the `Docs Publish` workflow needs: repo Settings → Pages →
  Source = "GitHub Actions", **and** a `v*` **tag** deployment-branch policy on the `github-pages`
  environment. Without the tag policy the environment defaults to `main`-only and a tag deploy is
  rejected (Build succeeds, Deploy fails).
- **Validate workflows with actionlint** if you add/edit any (the repo's `Actionlint` check runs on PRs).
