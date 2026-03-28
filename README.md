<!--
Keep this file as a lightweight front door for the workspace.
Do not duplicate the full install matrix or deep onboarding from gstack/README.md.
-->

# skills

Install gstack from the canonical upstream repo:

```bash
git clone https://github.com/garrytan/gstack.git ~/.codex/skills/gstack && cd ~/.codex/skills/gstack && ./setup --host codex
```

This workspace contains the `gstack/` project locally, but the install flow above uses the upstream `garrytan/gstack` source. For Claude setup, Codex/Gemini/Cursor variants, and the full install matrix, start with [gstack/README.md#install--takes-30-seconds](gstack/README.md#install--takes-30-seconds) and [gstack/README.md#codex-gemini-cli-or-cursor](gstack/README.md#codex-gemini-cli-or-cursor).

## What lives here

This repo is a small workspace wrapper around the actual `gstack` project, which lives in [`gstack/`](gstack/). It also carries standalone skills and vendored skill packs for personal use. If you landed on the repo root and want to understand the project quickly, use the links below instead of treating the root as a second copy of the product docs.

Custom local skills in this repo:
- [`quick-shoutout/`](quick-shoutout/) — deployment scaffold/publish helper skill (ported from `latentvibe-publish` and invokable as `quick-shoutout`).
- [`long-horizon-planner/`](long-horizon-planner/) — planning skill for long-running tasks using durable control files (`Prompt.md`, `Plans.md`, `Implement.md`, `Documentation.md`), now able to delegate active milestones to Superpowers-style execution workflows.
- [`randomradio-upgrade/`](randomradio-upgrade/) — upgrade helper skill to refresh managed skills from the latest `randomradio/skills` repository state.
- [`superpowers/`](superpowers/) — vendored snapshot of `obra/superpowers` for milestone-level planning and execution workflows.

Install `quick-shoutout` into your Codex skills directory:

```bash
cd quick-shoutout && ./scripts/install_skill.sh --target-dir "$HOME/.codex/skills" --force
```

Install `long-horizon-planner` into your Codex skills directory:

```bash
cd long-horizon-planner && ./scripts/install_skill.sh --target-dir "$HOME/.codex/skills" --force
```

Install `randomradio-upgrade` into your Codex skills directory:

```bash
cd randomradio-upgrade && ./scripts/install_skill.sh --target-dir "$HOME/.codex/skills" --force
```

Upgrade managed skills to latest:

```bash
~/.codex/skills/randomradio-upgrade/scripts/upgrade_skills.sh
```

Upgrade only `long-horizon-planner`:

```bash
~/.codex/skills/randomradio-upgrade/scripts/upgrade_skills.sh --skills long-horizon-planner
```

Scaffold long-horizon planning docs in a repo (default output: `docs/long-horizon/`):

```bash
~/.codex/skills/long-horizon-planner/scripts/init_long_horizon_workspace.sh --root .
```

Generated files:
- `docs/long-horizon/Prompt.md`
- `docs/long-horizon/Plans.md`
- `docs/long-horizon/Implement.md`
- `docs/long-horizon/Documentation.md`

Run objective-first loop execution (v0.1):

```bash
~/.codex/skills/long-horizon-planner/scripts/run_long_horizon_loop.sh --cwd . --engine codex --max-iterations 20
```

Claude backend example:

```bash
~/.codex/skills/long-horizon-planner/scripts/run_long_horizon_loop.sh --cwd . --engine claude --engine-bin claude --max-iterations 20
```

Custom output directory example:

```bash
~/.codex/skills/long-horizon-planner/scripts/init_long_horizon_workspace.sh --root . --dir docs/agent-control
```

## Repo map

- [`gstack/README.md#quick-start-your-first-10-minutes`](gstack/README.md#quick-start-your-first-10-minutes) — what gstack is, who it is for, and the fastest path to a first useful run.
- [`gstack/README.md#install--takes-30-seconds`](gstack/README.md#install--takes-30-seconds) — full install instructions.
- [`gstack/README.md#codex-gemini-cli-or-cursor`](gstack/README.md#codex-gemini-cli-or-cursor) — non-Claude host setup and auto-detect install flow.
- [`gstack/CONTRIBUTING.md#quick-start`](gstack/CONTRIBUTING.md#quick-start) — contributor setup, dev mode, and test workflow.
- [`gstack/ARCHITECTURE.md#the-core-idea`](gstack/ARCHITECTURE.md#the-core-idea) — how the browser daemon, SKILL.md system, and generated docs fit together.
- [`gstack/CHANGELOG.md`](gstack/CHANGELOG.md) — release history and what changed recently.
- [`long-horizon-planner/SKILL.md`](long-horizon-planner/SKILL.md) — top-level orchestration skill for long-running work.
- [`superpowers/UPSTREAM.md`](superpowers/UPSTREAM.md) — upstream source, pinned commit, and refresh instructions for the vendored Superpowers skills.

## Go deeper

- Want to use gstack: start with [`gstack/README.md#quick-start-your-first-10-minutes`](gstack/README.md#quick-start-your-first-10-minutes).
- Want the install details first: go straight to [`gstack/README.md#install--takes-30-seconds`](gstack/README.md#install--takes-30-seconds).
- Want to contribute: read [`gstack/CONTRIBUTING.md#quick-start`](gstack/CONTRIBUTING.md#quick-start).
- Want to understand the internals: read [`gstack/ARCHITECTURE.md#the-core-idea`](gstack/ARCHITECTURE.md#the-core-idea).
- Want recent changes: scan [`gstack/CHANGELOG.md`](gstack/CHANGELOG.md).
- Want the long-running orchestration workflow: read [`long-horizon-planner/SKILL.md`](long-horizon-planner/SKILL.md).
- Want the vendored Superpowers snapshot details: read [`superpowers/UPSTREAM.md`](superpowers/UPSTREAM.md).
