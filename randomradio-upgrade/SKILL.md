---
name: randomradio-upgrade
description: Upgrade the randomradio plugin across platforms. Supports Claude Code (native plugin system) and Codex (flat skills directory). Auto-detects installed platforms by default.
---

# RandomRadio Upgrade

## Overview

Pull the latest `randomradio/skills` repo and install/update the plugin on all detected platforms.

**Supported platforms:**
- **Claude Code** — updates via `claude plugin update randomradio`
- **Codex** — flattens skills + agents into `~/.codex/skills/<name>/SKILL.md`

## Usage

Auto-detect platforms and upgrade all:

```bash
./scripts/upgrade_skills.sh
```

Upgrade Claude Code only:

```bash
./scripts/upgrade_skills.sh --target claude
```

Upgrade Codex only:

```bash
./scripts/upgrade_skills.sh --target codex
```

Upgrade all platforms:

```bash
./scripts/upgrade_skills.sh --target all
```

Explicit Codex skills directory:

```bash
./scripts/upgrade_skills.sh --target codex --codex-dir "$HOME/.codex/skills"
```

Dry run (show what would happen):

```bash
./scripts/upgrade_skills.sh --dry-run
```

Verbose output:

```bash
./scripts/upgrade_skills.sh --verbose
```

## How It Works

### Claude Code

1. Pulls latest repo into `~/.cache/randomradio-skills/repo/`
2. Registers `plugins/` as a local marketplace (if not already registered)
3. Runs `claude plugin marketplace update` + `claude plugin update randomradio`

### Codex

1. Pulls latest repo into `~/.cache/randomradio-skills/repo/`
2. Copies each skill directory into `~/.codex/skills/<skill-name>/`
3. Copies each agent `.md` file as `~/.codex/skills/<agent-name>/SKILL.md`
4. Both skills and agents become flat Codex skills (same pattern as compound-engineering)

## Self-Update

The script updates itself from the latest repo state on each run.

## Validation

```bash
./scripts/validate.sh
```
