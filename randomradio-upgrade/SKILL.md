---
name: randomradio-upgrade
description: Upgrade the randomradio plugin across platforms, or safely remove all Codex personal skills while keeping built-in system skills. Use for RandomRadio updates and full personal-skill cleanup.
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
./randomradio-upgrade/scripts/upgrade_skills.sh
```

Upgrade Claude Code only:

```bash
./randomradio-upgrade/scripts/upgrade_skills.sh --target claude
```

Upgrade Codex only:

```bash
./randomradio-upgrade/scripts/upgrade_skills.sh --target codex
```

Upgrade all platforms:

```bash
./randomradio-upgrade/scripts/upgrade_skills.sh --target all
```

Explicit Codex skills directory:

```bash
./randomradio-upgrade/scripts/upgrade_skills.sh --target codex --codex-dir "$HOME/.codex/skills"
```

Dry run (show what would happen):

```bash
./randomradio-upgrade/scripts/upgrade_skills.sh --dry-run
```

Verbose output:

```bash
./randomradio-upgrade/scripts/upgrade_skills.sh --verbose
```

## Uninstall All Personal Skills

Preview the personal skills that the script will remove:

```bash
./randomradio-upgrade/scripts/uninstall_personal_skills.sh --dry-run
```

Remove all personal skills without an interactive prompt:

```bash
./randomradio-upgrade/scripts/uninstall_personal_skills.sh --yes
```

Use `--codex-dir <path>` to select an explicit Codex skills directory. The
script removes top-level entries that contain `SKILL.md`. It keeps `.system`
and entries that are not skills.

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
./randomradio-upgrade/scripts/validate.sh
```
