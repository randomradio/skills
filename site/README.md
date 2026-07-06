# Skills Market

Static catalog page for `skills.icyzhao.com`.

## Generate Registry

```bash
node site/scripts/build-registry.mjs
```

The generator reads `plugins/randomradio/skills/*/SKILL.md` and writes
`site/registry.json`.

## Local Preview

```bash
cd site
python3 -m http.server 4173
```

Then open `http://localhost:4173`.

## Deployment

The `Skills Market` GitHub Actions workflow publishes `site/` to GitHub Pages
on pushes to `master`.

One-time GitHub setup:

1. Open repository Settings -> Pages.
2. Set Build and deployment Source to GitHub Actions.
3. Set the custom domain to `skills.icyzhao.com`.
4. Point the DNS record for `skills.icyzhao.com` at the repository's GitHub
   Pages host. For this repository, that host is `randomradio.github.io`.

GitHub stores the custom domain setting for Actions-based Pages deployments, so
the workflow only needs to upload and deploy the static artifact. Do not rely on
a committed `CNAME` file for this workflow; GitHub ignores it for custom
Actions-based Pages publishing.
