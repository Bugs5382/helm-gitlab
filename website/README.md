# 📚 helm-gitlab documentation site

The [Docusaurus](https://docusaurus.io/) site for **helm-gitlab**, published at
https://bugs5382.github.io/helm-gitlab/.

## 🧩 Prerequisites

- Node.js >= 20
- npm

## 💻 Local development

```bash
npm install
npm start
```

Starts a local dev server with hot reload at http://localhost:3000.

## 🏗️ Build

```bash
npm run build
```

Generates the static site into `build/`. Preview the production build with
`npm run serve`.

## 🚀 Deployment

Deployment is **automated** — do not deploy by hand. The `Docs Publish` GitHub
Actions workflow (`.github/workflows/docs-publish.yaml`) builds the site and
publishes it to GitHub Pages **on `vX.Y.Z` release tags only**, not on merges to
`main`. Cutting a release tag is what ships the docs.
