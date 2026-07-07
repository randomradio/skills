# Skills Market Publish

`rr:skills-market-publish` packages the release workflow for RandomRadio skills:
update skills, verify CI inputs, publish to `master`, let GitHub Actions
regenerate and commit the public registry, and configure `skills.icyzhao.com`
through GitHub Pages and Cloudflare DNS.

Use it for additive skill releases, registry refreshes, CI/CD repair, and
one-time setup or repair of the public skills market hosting path.

For Compound Engineering-derived skills, this workflow also preserves upstream
lineage through `plugins/randomradio/skills/upstream.json` so the collection can
adopt upstream improvements without losing local release ownership.
