---
name: randomradio-upgrade
description: Upgrade installable RandomRadio-managed skills from the latest GitHub repository state into your local Codex/Claude skills directory. Use when you want to refresh everything this repo can install, or a selected subset with --skills.
---

# RandomRadio Upgrade

## Overview

Use this skill to update managed local skills from the latest `randomradio/skills` repository.

Managed skills (default):
- Auto-discovers every top-level skill in the repo that ships `scripts/install_skill.sh`
- Reinstalls all of them unless you pass `--skills ...`
- Keeps `--skills` as an explicit subset filter

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
- Auto-discovers installable skills from the repo when `--skills` is omitted
- Reinstalls each selected skill with `--force --non-interactive`
- Writes/refreshes `.randomradio-skill-meta` in each installed skill
- Prints repo commit and upgrade summary
- Vendored packs without `install_skill.sh` are not installed by this command; those update when you pull the repo checkout that contains them

## Validation

```bash
./scripts/validate.sh
```
