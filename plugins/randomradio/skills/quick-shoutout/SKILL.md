---
name: rr:quick-shoutout
description: Standardize and automate low-friction publishing of app repositories to latentvibe.com on Cloudflare using shell-only workflows. Use when creating or updating deployment workflows for API-only apps, agent-skill catalogs, fullstack apps (frontend + backend), and staging/dev environments with Cloudflare Tunnel.
---

# Quick Shoutout

## Overview

Use a single deployment contract for all app repos and scaffold it with one shell command.

This skill is intentionally shell-first so any coding LLM agent can run it without Python dependencies.

## LLM Interaction Contract

When using this skill, collect only the minimum required inputs from the user:
- `app_name` (lowercase, hyphenated)
- `app_type` (`api`, `skills`, `fullstack`, `stage-dev`)
- `dev_user` (for dev tunnel hostname)
- `repo_root` (defaults to current directory)
- Overwrite policy (`--force` or preserve existing files)

If any input is missing, either:
- Ask the user directly in one concise message, or
- Run `scripts/init_repo.sh` interactively and let the script prompt.

## Installation (Shell Only)

Install or refresh the skill in a target skills directory:

```bash
./scripts/install_skill.sh
```

Explicit install target:

```bash
./scripts/install_skill.sh --target-dir "$HOME/.codex/skills" --force
```

The installer auto-detects a skills directory from:
1. `$CODEX_HOME/skills`
2. `~/.codex/skills`
3. `~/.claude/skills`

## Scaffold Workflow

In the app repository root:

```bash
~/.codex/skills/quick-shoutout/scripts/init_repo.sh \
  --app notes \
  --type fullstack \
  --user "$USER" \
  --repo-root .
```

Interactive mode (agent/user guided):

```bash
~/.codex/skills/quick-shoutout/scripts/init_repo.sh
```

Generated files:
- `latentvibe.yml`
- `wrangler.toml` (api/fullstack)
- `.github/workflows/latentvibe-publish.yml`
- `scripts/publish.sh`
- `Makefile`
- `cloudflare/tunnel.dev.yml`

## Deployment Contract

Hostnames:
- Production frontend: `<app>.latentvibe.com`
- Production API: `api.<app>.latentvibe.com`
- Staging frontend/API: `<app>.stg.latentvibe.com`, `api.<app>.stg.latentvibe.com`
- Developer tunnel: `<app>.<user>.dev.latentvibe.com`

Branch mapping:
- `main` -> production deploy
- `staging` -> staging deploy
- feature branches -> preview URLs

## App Type Rules

### API App

- Deploy Worker on `main` and `staging`.
- Use `wrangler.toml` routes for production and staging.

### Skills App

- Deploy static catalog/docs with Pages.
- Use versioned artifacts under `skills.latentvibe.com`.

### Fullstack App

- Deploy backend with Worker.
- Deploy frontend with Pages.
- Keep API host on `api.<app>...` and web host on `<app>...`.

### Stage-Dev App

- Focus on staging and tunnel-only flows.
- Use `make tunnel-dev` for shareable development access.

## Secrets And Tokens

Print app-specific secret requirements:

```bash
~/.codex/skills/quick-shoutout/scripts/show_secrets.sh --type fullstack
```

Detailed reference:
- `references/secrets-and-tokens.md`

## Validation (Shell Only)

Run quick validation without Python:

```bash
./scripts/validate.sh
```

## Safety Defaults

- Use least-privilege API tokens.
- Keep production hosts public only when intended.
- Protect `*.stg.latentvibe.com` and `*.dev.latentvibe.com` with Access.
- Use Quick Tunnels only for temporary demos.

## Output Expectations

When applying this skill to a repo:
- Create or update deployment files without deleting unrelated user files.
- Report exactly which files changed.
- Report required secrets for the selected app type.
- Report final commands for local publish and CI verification.
