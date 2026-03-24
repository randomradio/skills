---
name: long-horizon-planner
description: Plan and steer long-running coding tasks with durable control docs, then execute an objective-first work/review loop with resumable runtime state when needed.
---

# Long Horizon Planner

## Overview

Use this as a hybrid long-horizon system:
- control plane: `Prompt.md`, `Plans.md`, `Implement.md`, `Documentation.md`
- execution plane: objective-first loop runner in `.codex/long-horizon-loop/`

The planning docs remain source of truth; loop artifacts provide reliable execution telemetry and resume support.

## Update Check On Invocation

When this skill is loaded, run:

```bash
./scripts/check_for_updates.sh --quiet
```

If status is `update_available`, tell the user to run:
- `$randomradio-upgrade`
- or `~/.codex/skills/randomradio-upgrade/scripts/upgrade_skills.sh --skills long-horizon-planner`

## Quick Start

Initialize planning docs in a repo:

```bash
./scripts/init_long_horizon_workspace.sh --root .
```

Validate planning docs shape:

```bash
./scripts/validate_long_horizon_workspace.sh --root .
```

Run objective-first loop execution:

```bash
./scripts/run_long_horizon_loop.sh \
  --cwd . \
  --engine codex \
  --max-iterations 20 \
  --validate-cmd "npm test"
```

Resume an interrupted run:

```bash
./scripts/run_long_horizon_loop.sh --cwd . --engine codex --resume
```

Stop a running loop safely:

```bash
touch ./.codex/long-horizon-loop/STOP
```

Install this skill into Codex skills:

```bash
./scripts/install_skill.sh --target-dir "$HOME/.codex/skills" --force
```

## Modes

1. Planning mode
- Capture objective, acceptance criteria, constraints, and scope in `Prompt.md`.
- Decompose milestones and verification in `Plans.md`.
- Maintain execution contract in `Implement.md`.
- Keep `Documentation.md` synchronized with shipped behavior.

2. Execution mode
- Run `run_long_horizon_loop.sh` for mandatory work/review iterations.
- Work phase emits machine-readable work JSON.
- Review phase emits machine-readable decision JSON (`SHIP`/`REVISE`/`BLOCKED`).
- Optional verification commands are evidence, not the task definition.
- Runtime state lives in `.codex/long-horizon-loop/` and supports resume.

## Execution Contract (v0.1)

- Engine interface is pluggable; v0.1 ships `codex` and `claude` implementations.
- `--engine claude` is supported for non-interactive structured runs when `claude` CLI is available.
- Completion is strict dual-gate:
  - work reports `COMPLETE`
  - reviewer decides `SHIP`
  - optional verification (if configured) passes
  - progress gate passes or no-change is explicitly justified
- Blocking is explicit:
  - worker reports `BLOCKED` with reason
  - reviewer confirms blocker is genuine/external
  - runner writes `RALPH-BLOCKED.md` and stops `task_blocked`

## Planner Sync Behavior

The runner auto-syncs planner docs each iteration when they exist:
- `Plans.md` -> `## Loop Status`
- `Documentation.md` -> `## Runtime Execution Notes`

At startup, if no explicit prompt/objective is supplied, the runner seeds objective and acceptance criteria from:
- `docs/long-horizon/Prompt.md` sections `## Objective` and `## Acceptance Criteria`

## Core Runtime Files

Under `.codex/long-horizon-loop/`:
- `state.env`
- `objective.md`
- `acceptance-criteria.md`
- `feedback.md`
- `work-summary.md`
- `review-feedback.md`
- `review-result.txt`
- `RALPH-BLOCKED.md`
- `.loop-complete`
- `work-schema.json`
- `review-schema.json`
- `iteration-history.md`
- `run-summary.md`
- `events.log` / `events.jsonl`
- `validation/`
- `codex/iteration-<n>-<phase>-attempt-<m>.jsonl`

## References

- `references/openai-long-horizon-notes.md`
- `references/loop-runbook.md`
