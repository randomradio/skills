# Skills Market Publish

`rr:skills-market-publish` packages the release workflow for RandomRadio skills:
update skills, regenerate the public registry, verify CI inputs, publish to
`master`, and configure `skills.icyzhao.com` through GitHub Pages and Cloudflare
DNS.

Use it for additive skill releases, registry refreshes, and one-time setup or
repair of the public skills market hosting path.

For Compound Engineering-derived skills, this workflow also preserves upstream
lineage through `plugins/randomradio/skills/upstream.json` so the collection can
adopt upstream improvements without losing local release ownership.
