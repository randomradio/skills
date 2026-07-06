# CI and Registry Contract

The skills market is a static site generated from repository state. The repo is
the source of record; the public site is a derived artifact.

## Required Files

| Path | Purpose |
|---|---|
| `plugins/randomradio/skills/*/SKILL.md` | Published skill definitions |
| `plugins/randomradio/.claude-plugin/plugin.json` | Collection metadata and version |
| `.claude-plugin/marketplace.json` | Marketplace entry and public skill count |
| `site/scripts/build-registry.mjs` | Registry generator |
| `site/registry.json` | Committed catalog consumed by the static site |
| `.github/workflows/skills-market.yml` | CI validation and GitHub Pages deploy |

## Additive Skill Release Checklist

1. Add the skill directory and any references/scripts.
2. Keep `name: rr:<skill-id>` in frontmatter.
3. Update `README.md` if the skill belongs in the short public table.
4. Update `.claude-plugin/marketplace.json` when the skill count changes.
5. Bump `plugins/randomradio/.claude-plugin/plugin.json` with a non-breaking
   semver increment.
6. Run `node site/scripts/build-registry.mjs`.
7. Verify `site/registry.json` contains the new skill id.

## Verification Commands

```bash
bash -n install.sh
bash -n randomradio-upgrade/scripts/install_skill.sh
bash -n randomradio-upgrade/scripts/upgrade_skills.sh
bash randomradio-upgrade/scripts/validate.sh
node site/scripts/build-registry.mjs
git diff --exit-code -- site/registry.json
node --check site/app.js
node --check site/scripts/build-registry.mjs
git diff --check
```

## GitHub Actions Behavior

Pull requests validate:

- installer/update shell syntax
- `randomradio-upgrade` structure
- registry freshness
- site JavaScript syntax
- required static site files

Pushes to `master` deploy `site/` through GitHub Pages after validation passes.

## Common Failures

| Symptom | Likely cause | Fix |
|---|---|---|
| CI says registry is stale | Skill files changed without rerunning generator | Run `node site/scripts/build-registry.mjs` and commit `site/registry.json` |
| Skill count is wrong on site | Marketplace/README updated but registry not rebuilt | Rebuild registry and inspect `collection.skillCount` |
| GitHub Pages deploy did not run | Commit not on `master`, workflow path filter missed files, or Actions disabled | Check branch, workflow file, and repository Actions settings |
| Generated timestamp keeps dirtying git | Generator lost existing `generatedAt` behavior | Preserve existing timestamp unless intentionally overridden |
