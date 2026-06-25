---
name: state-check
description: >-
  Atomic Gate 4: confirm the conditions for rule-based execution are intact right before a SPECIFIC
  entry. Use this skill WHENEVER the user is about to act on a pre-entry impulse on a particular trade
  and is NOT already in a loss spiral — "am I okay to take this", "I feel like chasing this breakout",
  "tempted to size up on conviction just this once", "I can't state my stop but I want in", or "am I
  forcing this entry". The presence of an urge to deviate from the plan is itself the disqualifier;
  returns GO or NO-GO. This is the single pre-entry gate, NOT the whole workflow: if the user is
  already losing / on tilt / has hit the daily max loss, that is risk-deescalation; if they are
  managing a position already open, that is execution-rules; if they want the full day's process run,
  that is trade-discipline. Process only.
---

# State Check — Gate 4  (atomic)

**Purpose:** Discipline is a state. This gate catches the moment a feeling is about to override a rule.

**NO-GO if ANY is true**
- Already hit today's max loss.
- Acting on a "make-it-back" or FOMO impulse.
- Chasing an entry that is already extended past plan.
- About to size up because of "conviction."
- Cannot state the full plan (entry/stop/target/size) in one sentence.

The urge to deviate is the signal, not market information. **Pause 30–60 seconds** — impulses decay,
edges do not. If actively losing/tilting, run `risk-deescalation` instead.

**Verdict:** `GO` = none of the above is true and you can state the full plan (entry/stop/target/size)
in one sentence · `NO-GO` = any item present → do not enter; re-run once the impulse has passed.
**Next:** `cost-check`.
---

*Scope: process only — not financial advice, no buy/sell calls, no price predictions. Trading is treated as a logical, rule-based system; an urge to deviate is a signal to defer to the plan, never an input. Correct process is necessary, not sufficient: most day traders lose net of costs.*
