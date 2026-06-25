---
name: trade-discipline
description: >-
  Top-level router and sequencer for a logical, rules-based momentum / small-cap day-trading
  discipline system, composed of atomic single-purpose sub-skills. Use this skill WHENEVER the user
  wants to run a full trading workflow rather than a single step — e.g. "run my trading day", "should
  I take this trade?", "walk me through this setup", "help me trade with discipline", or "set up my
  whole process". It decides which atomic skill to invoke and in what order, and enforces that ALL
  pre-trade gates pass before any entry. Use it only for the MULTI-step workflow or a full candidate
  evaluation. For a single isolated step defer to that atom directly: just sizing → trade-planner,
  just journaling → trade-journal, just a drawdown/tilt reset → risk-deescalation, just an
  am-I-okay-to-enter impulse check → state-check, just screening one name → trade-screen. Process
  only; never recommends buys/sells or predicts prices.
---

# Trade Discipline — Orchestrator

A logical decision system, split into atomic skills so each step is independently runnable and
testable. This skill sequences them. **Prime directive: protect the account first** — survival is the
strategy. Emotion is a deviation signal, never an input; when an urge appears, defer to the plan.

## The pipeline (each box is its own atomic skill)

```
PER SESSION:        premarket-prep  ->  regime-check
PER CANDIDATE:      trade-screen (G1) -> setup-match (G2) -> trade-planner (G3)
                    -> state-check (G4) -> cost-check (G5)   [ALL must GO]
IN A POSITION:      execution-rules
ON DRAWDOWN/TILT:   risk-deescalation        (overrides; run first if user is losing)
AFTER CLOSE:        trade-journal
WEEKLY:             weekly-audit  +  consistency-audit
```

## Routing

- "Run my day" / "trade with discipline" → premarket-prep → regime-check, then loop the gates per name.
- "Should I take this trade?" → run the five gates **in order**: trade-screen → setup-match →
  trade-planner → state-check → cost-check. Any NO-GO halts the chain. A NO-GO is a success.
- "I'm in a trade / move my stop / take profit?" → execution-rules.
- "I keep losing / on tilt / hit max loss" → risk-deescalation FIRST, calmly, before anything else.
- "Log / review my day" → trade-journal. "Review my week / size up?" → weekly-audit (+ consistency-audit).
- A single isolated step → call that atomic skill directly; don't run the whole chain.

## How this composes
Skills do not call each other programmatically — this orchestrator *is* the sequence. When the
matching atom is installed, run it and treat its SKILL.md as the source of truth for that step. When
only this orchestrator is installed, the criteria below let the chain run end-to-end on their own.

## Gate criteria — inline fallback
**Session**
- `premarket-prep` — risk/trade 1% (hard cap 2%); daily max loss = 3R; list catalysts; watchlist 5–10; if nothing qualifies, zero trades is the correct answer.
- `regime-check` — TRADE (clean follow-through) · REDUCE (mixed → A+ only) · STAND-ASIDE (flat/choppy).

**Per-candidate gates — ALL must be GO to enter:**

| Gate | Skill | GO requires |
|---|---|---|
| G1 | `trade-screen` | price ~$1–20 · float <20M (prime <10M) · rvol ≥5× (≥3× min) · real catalyst · already up ≥~10%/in play. GO only if **all five**. |
| G2 | `setup-match` | chart is a *clean* instance of one of your 1–2 predefined, backtested setups; else NO-GO. |
| G3 | `trade-planner` | entry + stop at a PRIOR structural level (not the breakout) + target + computed size, all pre-set; run the sizer; GO only if R:R ≥ 2 and size > 0. |
| G4 | `state-check` | NO-GO if: max loss already hit · make-it-back/FOMO impulse · chasing an extended entry · sizing up on "conviction" · can't state the full plan in one sentence. |
| G5 | `cost-check` | net expected move clears commissions + borrow/locate + slippage + taxes/FX with room to spare. |

**In-trade** `execution-rules` — never widen a stop; no averaging down; scale out at ≥2R and move stop to break-even; cut on invalidation.
**Override** `risk-deescalation` — trigger on daily max loss / 2 red days / 3 rule-breaks → cut size to 25–50%, risk ~0.5%, cap 1–3 trades/day until green & rule-clean.

## Hard rule
Never enter unless Gates 1–5 are all GO. State each gate's verdict explicitly. Show math from the
trade-planner script; never hand-wave numbers.
---

*Scope: process only — not financial advice, no buy/sell calls, no price predictions. Trading is treated as a logical, rule-based system; an urge to deviate is a signal to defer to the plan, never an input. Correct process is necessary, not sufficient: most day traders lose net of costs.*
