---
name: risk-deescalation
description: >-
  Atomic circuit-breaker for ACTIVE drawdown or tilt. Use this skill WHENEVER the user is currently
  losing or rattled after losses — "I keep losing", "I am on tilt", "down big / bad day", "I blew up",
  "I hit my max loss", "two red days", "I'm revenge trading", or "I cannot stop trading". It OVERRIDES
  the normal pipeline: run it first, calmly. It throttles size, risk, and trade count until disciplined
  green days return. A single pre-entry urge when the user is NOT already in a loss spiral is
  state-check, not this; setting the day's loss budget in advance is premarket-prep. Prioritize the
  protocol over analysis; do not pile on. Process only; supportive tone.
---

# Risk De-escalation  (atomic, overrides the pipeline)

**Purpose:** Losing is in-budget; *deviating* ends accounts. After losses the probability of further
deviation rises, so mechanically lower the stakes while rebuilding.

**Trigger if ANY:** hit the daily max loss, two consecutive red days, or three rule-breaks in a session.

**Protocol** (until you string together green, rule-clean days):
1. Cut max share size to **25–50%** of normal.
2. Cut risk per trade to **~0.5%**; cut daily max loss to **1/4–1/2** of normal.
3. Cap to **1–3 trades/day**, A+ setups only.
4. Resume normal size only after a defined run of disciplined, profitable sessions.

If the user is spiraling, lead with this calmly and keep it short — the logical intervention is
*smaller and slower*, not more analysis.
---

*Scope: process only — not financial advice, no buy/sell calls, no price predictions. Trading is treated as a logical, rule-based system; an urge to deviate is a signal to defer to the plan, never an input. Correct process is necessary, not sufficient: most day traders lose net of costs.*
