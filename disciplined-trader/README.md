# Trade Discipline — Atomic Skill Suite

The momentum day-trading operating loop, decomposed into **single-responsibility skills**. Each does
one thing, triggers independently, and chains into the next. A thin **orchestrator** sequences them
and enforces the one hard rule: no entry unless every pre-trade gate is GO.

> Process only — not financial advice, no buy/sell calls, no price predictions. Trading is treated as
> a logical, rule-based system; an urge to deviate is a signal to defer to the plan, never an input.

## Architecture

```
PER SESSION       premarket-prep  ->  regime-check
PER CANDIDATE     trade-screen(G1) -> setup-match(G2) -> trade-planner(G3)
                  -> state-check(G4) -> cost-check(G5)      [ALL must GO -> entry]
IN A POSITION     execution-rules
ON DRAWDOWN/TILT  risk-deescalation        (overrides; run first when losing)
AFTER CLOSE       trade-journal
WEEKLY            weekly-audit  +  consistency-audit
                          ^ all routed by: trade-discipline (orchestrator)
```

## The 13 skills

| Skill | Role | One-line job |
|---|---|---|
| `trade-discipline` | Orchestrator | Routes/sequences the atoms; enforces all-gates-GO before entry. |
| `premarket-prep` | Session setup | Set the day risk budget, scan catalysts, build the watchlist. |
| `regime-check` | Session setup | TRADE / REDUCE / STAND-ASIDE based on whether the niche is moving. |
| `trade-screen` | Gate 1 | Five-filter screen → CANDIDATE / REJECT (filter, not a rec). |
| `setup-match` | Gate 2 | Is the chart a clean instance of one of my 1–2 setups? |
| `trade-planner` | Gate 3 | Entry/stop/target/size + R:R ≥ 2. Runs the risk calculator. |
| `state-check` | Gate 4 | Are the conditions for rule-based execution intact? |
| `cost-check` | Gate 5 | Does the edge survive fees (gross vs net)? |
| `execution-rules` | In-trade | Never widen a stop, no averaging down, scale out, cut mechanically. |
| `risk-deescalation` | Override | Drawdown throttle; cut size/risk/trades after losses. |
| `trade-journal` | Post-trade | Capture/reflection in Notion (Trade Threads + Trading Notes); numbers (R, rule adherence) stay in the CSV. |
| `weekly-audit` | Weekly | Expectancy + scaling decision (up only on evidence). |
| `consistency-audit` | Weekly | Score 10 rule-following behaviors; green-but-broke = variance. |

## Install

Installable `.skill` packages are in **`dist/`**. In Claude: Settings → Capabilities/Skills → add
each `.skill` file. Install `trade-discipline` (the orchestrator) plus whichever atoms you want.
Skills don't invoke each other programmatically — the orchestrator carries the full sequence **and**
each gate's thresholds inline, naming the steps so they map to the matching standalone atoms. So it
runs the whole loop on its own; each atom also works standalone; and if you install both, the atom's
SKILL.md is the source of truth for its step.

## Shared resources (bundled where needed)
- `trade-planner` and `weekly-audit` each bundle `scripts/position_sizer.py` (sizing / expectancy).
  The two copies are kept **identical** — edit one, copy to the other (skills can't share a sibling's files).
- `trade-journal` bundles `assets/trade_journal_template.csv` (the numbers `weekly-audit` reads) and
  `references/notion-schema.md`; its reflection layer lives in Notion under the **TradingJournal** hub
  (Trade Threads + Trading Notes), whose IDs it resolves on first run and caches to
  `~/.config/trading-journal/notion.json` — never hard-coded in the skill.

## Why atomic?
Single responsibility means each step is independently triggerable ("just size this", "just reset me
after a bad day"), independently testable, and replaceable without touching the rest. The orchestrator
holds the sequence and the thresholds, so the full loop runs whether or not the individual atoms are installed.
