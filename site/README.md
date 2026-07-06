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

## Deploy Shape

The `site/` directory is static. It can be used as a Cloudflare Pages output
directory once `skills.icyzhao.com` is pointed at this repository.
