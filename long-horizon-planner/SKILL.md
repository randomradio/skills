---
name: long-horizon-planner
description: Plan and steer long-running coding tasks by creating and maintaining durable markdown control files (Prompt.md, Plans.md, Implement.md, Documentation.md). Use when work will span many milestones, take hours or days, require checkpointing, or needs resumable execution without losing context.
---

# Long Horizon Planner

## Overview

Use file-based planning to extend execution horizon and keep work coherent across long runs.
Treat `Prompt.md`, `Plans.md`, `Implement.md`, and `Documentation.md` as the source of truth for intent, plan, operating contract, and user-facing docs.

## Quick Start

Initialize a planning workspace in the current repo:

```bash
./scripts/init_long_horizon_workspace.sh --root .
```

Default output directory:
- `docs/long-horizon/Prompt.md`
- `docs/long-horizon/Plans.md`
- `docs/long-horizon/Implement.md`
- `docs/long-horizon/Documentation.md`

Use a custom directory when needed:

```bash
./scripts/init_long_horizon_workspace.sh --root . --dir docs/agent-control
```

Validate that required files exist and contain core sections:

```bash
./scripts/validate_long_horizon_workspace.sh --root .
```

Install this skill into Codex skills:

```bash
./scripts/install_skill.sh --target-dir "$HOME/.codex/skills" --force
```

## Workflow

1. Capture intent in `Prompt.md`.
Write objective, acceptance criteria, constraints, non-goals, and assumptions before implementation.

2. Expand execution in `Plans.md`.
Break work into milestones with scope, key files, acceptance criteria, and verification commands.
Keep a risk register and decision log.

3. Lock operating rules in `Implement.md`.
Define autonomy level, iteration loop, validation cadence, blocked handling, and stop conditions.

4. Keep `Documentation.md` live.
Update setup, architecture, runbook, and troubleshooting as milestones land.
Do not defer documentation to the end.

5. Reconcile at checkpoints.
After each milestone, update:
- milestone status in `Plans.md`
- key decision notes in `Plans.md`
- docs reality in `Documentation.md`

## Operating Rules

- Use small, reviewable milestone slices.
- Run verification commands for each milestone and record outcomes.
- If ambiguity appears, decide explicitly and document it in `Plans.md` before continuing.
- If blocked, document blocker, attempted mitigations, and next unblocking action.
- Prefer deterministic outputs and explicit quality gates.

## Standard File Roles

- `Prompt.md`: Why and what success means.
- `Plans.md`: How work is sequenced and verified.
- `Implement.md`: How to execute continuously without drift.
- `Documentation.md`: What shipped and how to run/use it.

## Expected Output When Using This Skill

When this skill is applied to a repo, produce:
- A filled `Prompt.md` with concrete objective and acceptance criteria.
- A milestone-based `Plans.md` with risk register and verification checklist.
- An `Implement.md` contract that enables continuous execution.
- A `Documentation.md` draft that stays synced as implementation progresses.
- A short status summary of changed files and current next milestone.

## References

- For concise rationale and patterns from OpenAI long-horizon guidance, read:
  - `references/openai-long-horizon-notes.md`
