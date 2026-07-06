---
date: 2026-07-06
status: completed
owner: randomradio
scope: skill-creation
---

# Skills Market Publish Skill

## Goal

Package the repeatable workflow for publishing RandomRadio skills and the
public skills market into a reusable `rr:skills-market-publish` skill.

## Success Criteria

1. Add a new skill under `plugins/randomradio/skills/skills-market-publish/`.
2. Document runtime detection, GitHub Pages setup, Cloudflare DNS setup, CI
   verification, and publish gates.
3. Update repository README and marketplace metadata to include the new skill.
4. Regenerate `site/registry.json` with the new skill.
5. Commit and push the published skill to `master`.

## Verification

- Run `node site/scripts/build-registry.mjs`.
- Run shell syntax checks for installer/update scripts.
- Run `node --check` for site JavaScript.
- Run `git diff --check`.
- Confirm `site/registry.json` contains `skills-market-publish`.
