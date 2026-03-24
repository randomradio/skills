---
name: randomradio-upgrade
description: Upgrade RandomRadio-managed skills from the latest GitHub repository state into your local Codex/Claude skills directory. Use when you want to refresh long-horizon-planner, quick-shoutout, and randomradio-upgrade itself.
---

# RandomRadio Upgrade

## Overview

Use this skill to update managed local skills from the latest `randomradio/skills` repository.

Managed skills (default):
- `long-horizon-planner`
- `quick-shoutout`
- `randomradio-upgrade`

## Usage

Run upgrade with auto-detected skills directory:

```bash
./scripts/upgrade_skills.sh
```

Explicit target directory:

```bash
./scripts/upgrade_skills.sh --target-dir "$HOME/.codex/skills"
```

Upgrade only selected skills:

```bash
./scripts/upgrade_skills.sh --skills long-horizon-planner,randomradio-upgrade
```

Dry run:

```bash
./scripts/upgrade_skills.sh --dry-run
```

## Behavior

- Pulls latest commit from `https://github.com/randomradio/skills.git` (`master` by default)
- Reinstalls each selected skill with `--force --non-interactive`
- Writes/refreshes `.randomradio-skill-meta` in each installed skill
- Prints repo commit and upgrade summary

## Validation

```bash
./scripts/validate.sh
```
