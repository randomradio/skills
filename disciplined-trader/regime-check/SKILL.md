---
name: regime-check
description: >-
  Atomic check of whether the niche is tradeable right now. Use this skill WHENEVER the user asks if
  today/this session is worth trading — "is the market moving", "should I trade today", "is it a good
  day", "regime check", or "is there follow-through". Returns TRADE / REDUCE / STAND-ASIDE with the
  logic. A volatility strategy in a flat tape has negative expectancy, so standing aside is a valid
  output. Process only; not a market forecast or buy/sell call.
---

# Regime Check  (atomic)

**Purpose:** A momentum edge only exists when the niche is actually moving. Forcing it onto dead tape
is negative-expectancy by construction.

**Procedure** — assess today's conditions:
- Are low-float small-caps running with clean, sustained follow-through (not one-candle fades)?
- Is breadth of movers wide, or is it a single fluke?

**Verdict**
- **TRADE** — clear movement and follow-through. Proceed to the gates.
- **REDUCE** — mixed/thin. Cut size; A+ setups only.
- **STAND-ASIDE** — choppy/flat. The logical number of trades is low or zero.

**Next:** per candidate, run `trade-screen`.
---

*Scope: process only — not financial advice, no buy/sell calls, no price predictions. Trading is treated as a logical, rule-based system; an urge to deviate is a signal to defer to the plan, never an input. Correct process is necessary, not sufficient: most day traders lose net of costs.*
