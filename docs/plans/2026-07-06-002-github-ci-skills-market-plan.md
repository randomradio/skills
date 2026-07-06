---
date: 2026-07-06
status: completed
owner: randomradio
scope: github-ci
---

# GitHub CI for Skills Market

## Goal

Automate skill update checks and publish the static skills market to
`https://skills.icyzhao.com/` from the repository.

## Assumptions

- `master` is the release branch for the public skill collection.
- GitHub Pages is the deployment target for `skills.icyzhao.com`.
- The GitHub repository settings will point Pages at GitHub Actions, with the
  custom domain configured as `skills.icyzhao.com`.

## Success Criteria

1. Pull requests that change skills, installer scripts, or the site validate
   install/update scripts and regenerate `site/registry.json`.
2. CI fails when `site/registry.json` is stale.
3. Pushes to `master` deploy the static `site/` directory to GitHub Pages.
4. The deployment environment URL is `https://skills.icyzhao.com/`.

## Implementation

- Add `.github/workflows/skills-market.yml`.
- Keep registry generation deterministic by using the existing generator.
- Publish `site/` as a GitHub Pages artifact after validation passes.

## Verification

- Parse workflow YAML locally.
- Run shell syntax checks for installer/update scripts.
- Run `randomradio-upgrade/scripts/validate.sh`.
- Regenerate `site/registry.json` and assert no diff.
- Run Node syntax checks for the site scripts.
