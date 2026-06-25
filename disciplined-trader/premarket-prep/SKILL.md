---
name: premarket-prep
description: >-
  Atomic pre-session routine: set the day risk budget, scan for catalysts, and build a watchlist of
  names that pass the screen. Use this skill WHENEVER the user is preparing for a trading session —
  "prep for the day", "build my watchlist", "morning routine", "what is my risk budget today", or "get
  me ready to trade". Outputs a written day-plan and a candidate list; if nothing qualifies it
  concludes the logical number of trades today is zero. Process only; no buy/sell calls.
---

# Pre-Market Prep  (atomic)

**Purpose:** Decide, before emotion is in play, how much you may lose today and which names are even
eligible. Pre-deciding the budget is the logical move; it removes mid-session improvisation.

**Procedure**
1. **Risk budget.** Confirm account size and risk per trade (default 1%, hard cap 2%). Daily max
   loss = 3R (3 x per-trade risk $). Write it down; it is the day's hard stop.
2. **Catalyst scan.** List today's catalysts (earnings, regulatory news, contracts, offerings).
3. **Watchlist.** Keep only names that pass the screen (hand off each to `trade-screen`). 5–10 max.
4. **Zero-state.** If nothing qualifies, the correct number of trades is zero. Sitting out is a
   position, not a failure.

**Output:** a one-screen day-plan: account, risk%, daily max loss ($), and the watchlist.
**Next:** `regime-check`.
---

*Scope: process only — not financial advice, no buy/sell calls, no price predictions. Trading is treated as a logical, rule-based system; an urge to deviate is a signal to defer to the plan, never an input. Correct process is necessary, not sufficient: most day traders lose net of costs.*
