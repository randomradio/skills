# GENI — "Should I take this trade?"

I'll walk you through the five pre-trade gates **in order**. The rule is simple: **all five must be GO to enter.** Any single NO-GO halts the chain — and a NO-GO is a *successful* outcome, not a failure. This is process only, not financial advice; no buy/sell call, no price prediction.

Here's your setup as I have it:

| Field | Value |
|---|---|
| Ticker | GENI |
| Premarket move | +18% |
| Catalyst | FDA approval |
| Float | ~8M |
| Relative volume | ~6× |
| Price | $5.40 |
| Planned entry | $5.50 (breakout) |
| Planned stop | $5.20 |
| Planned target | $6.40 |
| Account | $8,000 |

---

## Gate 1 — Trade Screen  → **GO**

Need all five: price ~$1–20 · float <20M (prime <10M) · rvol ≥5× (≥3× min) · real catalyst · already in play / up ≥~10%.

- Price $5.40 → in the $1–20 band. PASS
- Float ~8M → under 20M, and under 10M so it's in the **prime** range. PASS
- rvol ~6× → above the 5× preferred threshold. PASS
- FDA approval → a real, hard catalyst. PASS
- Up 18% premarket → clearly in play. PASS

All five pass. **Gate 1: GO.**

---

## Gate 2 — Setup Match  → **CONDITIONAL / cannot confirm**

Requires the chart to be a *clean* instance of one of your **1–2 predefined, backtested setups**. Otherwise it's a NO-GO.

You've described a "bull flag near the highs," which is a legitimate, nameable momentum pattern. But I can't pass this gate *for* you, because the gate isn't "is this a bull flag?" — it's **"is this one of YOUR pre-defined, backtested setups, and is it clean?"** Two things you must answer honestly before this is a GO:

1. **Is the bull flag one of the 1–2 setups you've actually backtested and trade?** If you're pattern-matching it on the fly because the stock is moving, that's not your edge — that's the move pulling you in. NO-GO.
2. **Is it *clean*?** Tight flag, orderly pullback, holding the highs without wild wicks — versus a sloppy, wide, low-volume drift. Only a clean instance counts.

If yes to both → treat Gate 2 as GO and continue. If you're unsure, or it's "close enough," the gate is **NO-GO and you stop here.** I'll continue the walkthrough assuming a clean, pre-defined flag so you can see the rest of the math — but own that call.

---

## Gate 3 — Trade Planner  → **NO-GO (as planned)**

Requires: entry + stop **at a prior structural level (not the breakout)** + target + computed size, all pre-set; R:R ≥ 2 and size > 0.

**The math (1% risk on $8,000):**

| Item | Value |
|---|---|
| Risk per trade (1%) | **$80.00** |
| Risk per share ($5.50 − $5.20) | $0.30 |
| Reward per share ($6.40 − $5.50) | $0.90 |
| **R:R** | **3.00 : 1** |
| Position size ($80 ÷ $0.30) | **266 shares** |
| Position cost (266 × $5.50) | $1,463 (≈18% of account) |
| Actual $ risk at stop | $79.80 |
| Gain if target hits | +$239.40 |

The R:R is **3:1** — comfortably above the 2:1 minimum. Size is positive (266 shares) and dollar risk is a clean 1% ($80). On the numbers alone this looks great.

**But the gate fails on a structural rule:** your stop must sit at a **prior structural level**, *not* be hung off the breakout entry. A $5.50 entry with a $5.20 stop is a flat $0.30 / round-number stop — there's no evidence it's behind real support (e.g., the flag low, VWAP, or the prior consolidation shelf). A stop placed for *convenience of math* rather than *invalidation of the setup* is exactly what this gate exists to catch.

- If $5.20 genuinely **is** the structural level (flag low / breakout shelf the move would be wrong below), then this gate flips to GO at 266 shares.
- If $5.20 is just "30 cents," the stop is arbitrary → **NO-GO. Replan: find the level first, then derive the stop, then recompute size.** Don't reverse-engineer the level to fit the share count.

**Verdict as currently specified: NO-GO** — fix the stop logic before proceeding.

---

## Gate 4 — State Check  → **CAUTION (you must self-certify)**

NO-GO if any of: daily max loss already hit · make-it-back/FOMO impulse · chasing an extended entry · sizing up on "conviction" · can't state the full plan in one sentence.

Two flags I'd want you to confront honestly:

- **Chasing an extended entry.** The stock is already **+18%**. Entering a breakout *above* an extended premarket runner is the single most common way this setup turns into a top-tick. If the flag is mid-range and orderly that's defensible; if you're buying into a vertical move because it's "the FDA play of the day," that's FOMO wearing a chart pattern. Be ruthless here.
- **The one-sentence test:** *"I'm buying 266 shares of GENI at $5.50 on the flag breakout, stop $5.20 at the flag low, target $6.40, risking $80 for a 3R."* If you can say that and mean every clause — including that the stop is a real level — you pass. If any clause is hand-waved, you don't.

No make-it-back impulse or max-loss situation was mentioned, and size is at 1% (not sized up). So this is **GO only if** you can certify you're not chasing and you can state the plan cleanly. Otherwise NO-GO.

---

## Gate 5 — Cost Check  → **GO (likely), confirm one item**

Net expected move must clear commissions + borrow/locate + slippage + taxes with room to spare.

This is a long (you're buying the breakout), so there's **no borrow/locate cost** — that's the big one on small-cap names, and it doesn't apply here. Your edge per share is $0.90 (reward) vs. $0.30 (risk). Commissions are negligible on 266 shares. The one real cost on an 8M-float, +18%, 6× rvol mover is **slippage** — these names move fast and spreads widen. A few cents of slip on entry and exit still leaves plenty of room inside a $0.90 target. **Gate 5: GO**, provided you use a limit at $5.50 and don't market-chase the fill.

---

## Bottom line

| Gate | Verdict |
|---|---|
| G1 Trade Screen | **GO** |
| G2 Setup Match | **Cannot confirm for you** — only a GO if the flag is one of your pre-defined, backtested setups *and* it's clean |
| G3 Trade Planner | **NO-GO as planned** — R:R is fine (3:1, 266 sh, $80 risk), but the $5.20 stop must be a real structural level, not a flat $0.30 |
| G4 State Check | **Caution** — risk of chasing a +18% extended entry; pass only if you can state the plan in one sentence and mean it |
| G5 Cost Check | **GO** — long, so no borrow cost; just use a limit to control slippage |

**The chain halts at Gate 3. As specified, this is a NO-GO — do not enter yet.**

That's not "no forever." Your numbers are genuinely good — 3:1 R:R at a clean 1% risk is a setup worth wanting. The single thing standing between you and a GO is **proving the stop sits at a real level** (flag low / breakout shelf), and **confirming you're not chasing an already-extended runner.** Do that honestly:

- If $5.20 is the structural invalidation and the flag is your backtested setup and you can say the plan in one breath → all five gates are GO, **266 shares, risking $80 to make $239.**
- If you have to talk yourself into any of those → the gate did its job. **Skip it.** There's another setup tomorrow; there isn't another $8,000 account.

*Process only — not financial advice, no buy/sell call, no price prediction. Correct process is necessary but not sufficient: most day traders lose net of costs. An urge to override a gate is a signal to defer to the plan, never an input.*
