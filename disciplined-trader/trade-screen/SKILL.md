---
name: trade-screen
description: >-
  Atomic Gate 1: a five-filter screen that decides whether a stock is the right KIND to trade. Use
  this skill WHENEVER the user wants to vet or find a name — "screen this stock", "does X qualify",
  "is this tradeable", "find me names", or "run the filters". It returns CANDIDATE or REJECT and is a
  FILTER, never a recommendation; surfacing names that pass is fine, telling the user to buy is not.
  Process only; no price predictions.
---

# Trade Screen — Gate 1  (atomic)

**Purpose:** Restrict the universe to setups where a momentum edge can exist. Pass = ALL five.

| Filter | Pass condition | Logic |
|---|---|---|
| Price | ~$1–$20 | Volatile yet affordable; avoid sub-$1 micro-penny. |
| Float | <20M ideal, <10M prime | Low float amplifies price response to volume. |
| Relative volume | >=5x (>=3x min) | Confirms real, unusual participation. |
| Catalyst | earnings / regulatory / contract / offering / news | A cause for the move to continue or fail. |
| Already moving | up >=~10% / "in play" | Trade what is moving; do not predict. |

**Verdict:** `GO` = CANDIDATE (all five pass) · `NO-GO` = REJECT (name the failed filter). A filter,
not a buy recommendation.
**Next:** `setup-match`.
---

*Scope: process only — not financial advice, no buy/sell calls, no price predictions. Trading is treated as a logical, rule-based system; an urge to deviate is a signal to defer to the plan, never an input. Correct process is necessary, not sufficient: most day traders lose net of costs.*
