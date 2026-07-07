---
name: rr:skills-market-publish
description: >
  Publish and maintain a skills marketplace from this repository using the
  workflow-regenerated skills registry, GitHub Actions, GitHub Pages, and Cloudflare DNS.
  Triggers: "publish the skills market", "setup skills.icyzhao.com", "deploy
  the skill catalog", "automate skill updates", "add GitHub Pages CI", "set up
  Cloudflare DNS for skills", "turn these skills into a marketplace", "merge
  and push skills release", "non-breaking skill update", "showcase my skills".
argument-hint: "[domain, release branch, or brief publish request]"
version: 1.3.0
---

# Skills Market Publish

Publish RandomRadio skills as a versioned repository artifact and static skills
market. Use this when shipping new skills, refreshing the public catalog, or
setting up the one-time GitHub Pages + Cloudflare domain path.

<publish_request> #$ARGUMENTS </publish_request>

## Step 1: Detection Flow

Run fast checks from the repository root:

```bash
git status --short --branch
git remote -v
git branch --show-current
(node --version && echo NODE_OK) 2>/dev/null || echo NODE_MISSING
(bash -n install.sh && bash -n randomradio-upgrade/scripts/upgrade_skills.sh && echo SHELL_OK) 2>/dev/null || echo SHELL_CHECK_FAILED
(node scripts/compare-upstream-skills.mjs --check --allow-missing-upstream && echo UPSTREAM_MAP_OK) 2>/dev/null || echo UPSTREAM_MAP_MISSING_OR_INVALID
(gh --version && gh auth status && echo GH_AUTH_OK) 2>/dev/null || echo GH_UNAVAILABLE_OR_UNAUTHENTICATED
(dig +time=3 +tries=1 +short CNAME skills.icyzhao.com && echo DIG_OK) 2>/dev/null || echo DIG_UNAVAILABLE_OR_NO_RECORD
(curl -fsS --max-time 10 'https://dns.google/resolve?name=skills.icyzhao.com&type=CNAME' >/dev/null && echo DOH_OK) 2>/dev/null || echo DOH_UNAVAILABLE
```

**Decision tree:**

1. If `NODE_OK` and the registry generator exists -> use the local generator as
   the source of truth for `site/registry.json`.
2. If `GH_AUTH_OK` -> use `gh` for repository/workflow inspection; otherwise use
   normal `git` plus browser-based GitHub verification.
3. If Chrome/browser control is available and the task includes one-time Pages or
   DNS setup -> use the browser UI with the user's logged-in sessions.
4. If browser control is unavailable -> give the checklist in
   `references/pages-cloudflare-setup.md` and stop before claiming setup is done.
5. If `dig` fails but `DOH_OK` works -> trust DNS-over-HTTPS for public DNS
   verification and note local resolver limitations.
6. If `UPSTREAM_MAP_OK` -> use `plugins/randomradio/skills/upstream.json` before
   changing existing skills; otherwise add or repair the mapping and local
   compatibility contracts first.

## Step 2: Resolve Publish Defaults

| Parameter | Default if omitted | Rationale |
|---|---|---|
| `repo_root` | Current working directory | Skills are versioned in the active repo |
| `release_branch` | Current default branch, else `master` | Existing repository release branch |
| `domain` | `skills.icyzhao.com` | Public RandomRadio skills market |
| `dns_target` | `<github-owner>.github.io` | GitHub Pages custom-domain target |
| `site_dir` | `site/` | Static market output directory |
| `registry_command` | `node site/scripts/build-registry.mjs` | Repo-local catalog generator |
| `upstream_manifest` | `plugins/randomradio/skills/upstream.json` | Tracks CE lineage, local ownership, and sync compatibility contracts |
| `pages_source` | GitHub Actions | Matches `.github/workflows/skills-market.yml` |
| `dns_proxy` | Proxied | Production HTTPS is served by Cloudflare edge |
| `push_policy` | Push only after explicit publish/merge request | Avoid accidental releases |

Exit gate: identify the release branch, domain, and DNS target before changing
files or remote settings. If any value is ambiguous and cannot be inferred from
repo files or the user request, ask one concise question.

## Step 3: Update the Skill Collection

1. Add or modify skill files under `plugins/randomradio/skills/<skill-id>/`.
2. Keep frontmatter `name` as `rr:<skill-id>`.
3. If the skill is derived from Compound Engineering, add or update its entry in
   `plugins/randomradio/skills/upstream.json` before editing the skill body.
4. For existing `fork` skills, confirm `localCompatibility.preserve`,
   `localCompatibility.requiredMarkers`, and `localCompatibility.syncStrategy`
   describe the local changes that must survive upstream sync.
5. Run the upstream comparison when upstream skills are installed locally:

```bash
node scripts/compare-upstream-skills.mjs --write-report docs/upstream/compound-engineering-skill-report.md
```

6. Adopt upstream improvements by default when they are non-breaking, but keep
   RandomRadio local contracts: `rr:` names, install/update behavior, registry
   metadata, and deliberate workflow simplifications.
7. Update `README.md` and `.claude-plugin/marketplace.json` skill counts when the
   public collection changes.
8. Bump `plugins/randomradio/.claude-plugin/plugin.json` with a non-breaking
   semver increment for additive skills.
9. Run the registry generator locally as a preflight when preparing a reviewable
   diff. The GitHub workflow also regenerates the registry on `master`, commits
   `site/registry.json` with the Actions bot when it changed, and deploys the
   generated `site/` artifact.

```bash
node site/scripts/build-registry.mjs
```

Exit gate: `site/registry.json` must include every published skill, and
`node scripts/compare-upstream-skills.mjs --check --allow-missing-upstream` must
pass so CE-derived skills keep their local compatibility contracts.

## Step 4: Verify CI and Static Market

Read `references/ci-registry-contract.md`, then run:

```bash
bash -n install.sh
bash -n randomradio-upgrade/scripts/install_skill.sh
bash -n randomradio-upgrade/scripts/upgrade_skills.sh
bash randomradio-upgrade/scripts/validate.sh
node scripts/compare-upstream-skills.mjs --check --allow-missing-upstream
node --check scripts/compare-upstream-skills.mjs
node --check site/app.js
node --check site/scripts/build-registry.mjs
git diff --check
```

For UI-affecting market changes, run a local preview and inspect desktop/mobile:

```bash
cd site && python3 -m http.server 4173
```

Exit gate: do not publish while registry generation, syntax, whitespace, or
preview checks fail. Fix the smallest cause first.

## Step 5: Merge and Push the Release

Use this path when the user explicitly says to merge/push/release:

```bash
git fetch origin <release_branch>
git switch <release_branch>
git pull --ff-only origin <release_branch>
git merge --ff-only <feature_branch>
git push origin <release_branch>
```

If fast-forward is impossible, stop and show the divergence instead of forcing a
merge. After pushing, inspect GitHub Actions with `gh run list` when available,
or use the browser Actions tab.

Exit gate: the release branch on GitHub contains the market workflow, and the
workflow's `Commit regenerated registry` job has either confirmed the registry
is current or committed the regenerated `site/registry.json`.

## Step 6: Configure Pages and DNS

Read `references/pages-cloudflare-setup.md` before touching browser settings.

Required target state:

| Surface | Required value |
|---|---|
| GitHub Pages source | GitHub Actions |
| GitHub Pages custom domain | `skills.icyzhao.com` |
| Cloudflare DNS record | `CNAME skills -> randomradio.github.io` |
| Cloudflare proxy | Proxied |
| Cloudflare SSL/TLS mode | Full |
| HTTPS enforcement | Cloudflare redirects HTTP to HTTPS |

Exit gate: `https://skills.icyzhao.com/` must return a successful response and
`http://skills.icyzhao.com/` must redirect to HTTPS. GitHub native HTTPS may
remain pending when the Cloudflare record is proxied; report that as a GitHub UI
state, not as a public-site failure.

## Step 7: Respond to the User

Use this output structure:

1. **Release status**: branch, commit, push result, and workflow status if known.
2. **Market status**: skill count, registry update, and deployed site target.
3. **Hosting status**: GitHub Pages source, custom domain, Cloudflare DNS value,
   and HTTPS/certificate state.
4. **Upstream status**: CE-derived skills touched, manifest mode, compatibility
   result, and whether upstream comparison was run or skipped because upstream
   was unavailable.
5. **Verification**: commands run and pass/fail evidence.
6. **Follow-up**: only unresolved external waits, such as GitHub certificate
   issuance or DNS propagation.

## Reference Files

- `references/ci-registry-contract.md` -- CI, registry, and verification contract.
- `references/pages-cloudflare-setup.md` -- GitHub Pages and Cloudflare DNS setup.
