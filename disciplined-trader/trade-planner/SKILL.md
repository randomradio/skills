---
name: trade-planner
description: >-
  Atomic Gate 3: build the full pre-trade plan and run the risk math. Use this skill WHENEVER the user
  wants to plan or size a trade — "plan this trade", "size this", "what is my position size", "what is
  the R:R", or "where do I put my stop". It requires entry, an invalidation/stop at a PRIOR structural
  level (not the breakout), and target(s) BEFORE entry, then runs scripts/position_sizer.py to compute
  size, reward:risk, and the daily max loss, returning GO only if R:R is at least 2. Process only; no buy/sell
  calls.
---

# Trade Planner — Gate 3  (atomic)

**Purpose:** Move every decision out of the live, emotionally loaded moment by fixing all parameters
first. No plan, no trade.

**Require all four BEFORE entry**
1. **Entry trigger** — the specific event (e.g. break/hold of a level on volume).
2. **Invalidation / stop** — at a **prior structural level** (low of day / a level that held), NOT
   the breakout level (faked out too often). This price = "the thesis is logically wrong."
3. **Target(s)** — where you scale out.
4. **Size** — computed, never chosen by feel.

**Run the math (do not hand-wave).** The sizer ships in this skill's own `scripts/` folder; pass its
absolute path — don't assume the shell's working directory is the skill root (it usually isn't). If
you don't know where the skill lives, locate `position_sizer.py` first, then:
```
python /ABS/PATH/TO/trade-planner/scripts/position_sizer.py plan --account <$> --risk 0.01 \
    --entry <p> --stop <p> --target <p> [--side long|short]
```
It returns position size, Reward:Risk, and the 3R daily max loss.

**Verdict:** `NO-GO` = R:R < 2 or computed size is 0 · `GO` = otherwise (still must clear Gates 4 & 5).
**Next:** `state-check`.
---

*Scope: process only — not financial advice, no buy/sell calls, no price predictions. Trading is treated as a logical, rule-based system; an urge to deviate is a signal to defer to the plan, never an input. Correct process is necessary, not sufficient: most day traders lose net of costs.*
