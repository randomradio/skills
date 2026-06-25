---
name: weekly-audit
description: >-
  Atomic weekly statistics and scaling decision. Use this skill WHENEVER the user reviews a week or
  asks about sizing up — "review my week", "should I size up", "what is my expectancy", or "are my
  stats good enough to scale". It computes win%, avg win/loss (R), expectancy, profit concentration,
  and rule-break rate via scripts/position_sizer.py (expectancy --journal), then gives a scale-up /
  hold / scale-down verdict. Size is earned by evidence. Process only.
---

# Weekly Audit  (atomic)

**Purpose:** Let evidence, not feeling, decide size. Compute from the journal. The sizer ships in this
skill's own `scripts/` folder; pass its absolute path — don't assume the shell's working directory is
the skill root. If unsure where the skill lives, locate `position_sizer.py` first, then:
```
python /ABS/PATH/TO/weekly-audit/scripts/position_sizer.py expectancy --journal <your_journal.csv>
```
Reports win%, avg win (R), avg loss (R), payoff, **expectancy (R)**, rule-break rate, and profit
**concentration** (top-3 winners' share of gross profit — a high share means the edge leans on a few
lucky trades).

**Scaling verdict**
- **SCALE UP (modestly)** only if ALL hold: meaningful sample (aim >= ~20–30 trades, ideally more),
  expectancy positive **net of costs**, rule-break rate low and falling, not in de-escalation.
- **HOLD** if mixed.
- **SCALE DOWN immediately** after losses, rising rule-breaks, or a regime change.

Growth is a consequence of consistency, never a substitute for it.
**Pair with:** `consistency-audit`.
---

*Scope: process only — not financial advice, no buy/sell calls, no price predictions. Trading is treated as a logical, rule-based system; an urge to deviate is a signal to defer to the plan, never an input. Correct process is necessary, not sufficient: most day traders lose net of costs.*
