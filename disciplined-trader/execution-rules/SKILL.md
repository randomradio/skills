---
name: execution-rules
description: >-
  Atomic governance of an OPEN position. Use this skill WHENEVER the user is already in a trade or
  managing one live — "I am in a trade", "should I move my stop", "should I add", "when do I take
  profit", "it is going against me", or "should I hold". It enforces: never widen a stop, no averaging
  down, scale out into strength, move to break-even, and cut mechanically on invalidation. Process
  only; no buy/sell or hold recommendations beyond the user's own pre-set plan.
---

# Execution Rules  (atomic)

**Purpose:** Once in, the pre-set plan trades the position; the user does not. These rules block the
common feeling-over-rule failures.

- **Never widen a stop. Ever.** It only moves in your favor (break-even / trailing). Widening a stop
  is the clearest case of emotion overriding logic.
- **No averaging down into a loser.** Forbidden — it converts a bounded loss into an unbounded one.
- **Scale out into strength.** Take a partial at the first target (>=2R); move the stop on the rest to
  break-even so a winner cannot become a loser.
- **Cut mechanically.** Invalidation breaks (or first candle closes back through the level) → out.
- **One trade is one sample**, not a verdict. Execute the setup; ignore the running P&L.

**Verdict (each check-in):** `HOLD` per plan · `SCALE` (partial at ≥2R, move stop to break-even) ·
`CUT` (invalidation hit / first candle closes back through the level). Never `WIDEN`.
**Next (after close):** `trade-journal`.
---

*Scope: process only — not financial advice, no buy/sell calls, no price predictions. Trading is treated as a logical, rule-based system; an urge to deviate is a signal to defer to the plan, never an input. Correct process is necessary, not sufficient: most day traders lose net of costs.*
