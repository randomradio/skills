---
name: cost-check
description: >-
  Atomic Gate 5: confirm the edge survives real costs (gross vs net). Use this skill WHENEVER the user
  wants to validate that a thin edge clears fees — "will this survive fees", "net this out", "is the
  edge real after costs", or "account for commissions/borrow/slippage". Returns GO or NO-GO on a net
  basis. Published track records quote gross; the user lives on net. Process only.
---

# Cost Check — Gate 5  (atomic)

**Purpose:** A few-cents-per-share gross edge can be entirely consumed by costs. Evaluate the number
you actually keep.

**Subtract:** commissions, borrow/locate (for shorts), expected slippage, and taxes/FX.

**Verdict:** `GO` = the realistic **net** expected move clears all costs with room to spare · `NO-GO`
= it does not. If `GO` **and** Gates 1–4 are all GO → the trade may be executed under `execution-rules`.
---

*Scope: process only — not financial advice, no buy/sell calls, no price predictions. Trading is treated as a logical, rule-based system; an urge to deviate is a signal to defer to the plan, never an input. Correct process is necessary, not sufficient: most day traders lose net of costs.*
