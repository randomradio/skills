# Weekly Audit — Should you size up?

**Verdict: HOLD. Do not size up yet.**

I ran your journal through the weekly-audit sizer
(`position_sizer.py expectancy --journal my_trading_week.csv`). The math says
your edge is real *on this sample*, but two of the four scale-up conditions fail.
Size is earned by evidence, and the evidence isn't there yet.

## What the numbers say

| Metric | Value | Read |
|---|---|---|
| Sample (rows with realized_R) | 22 trades | Borderline-OK (aim for >= ~20-30, ideally more) |
| Win rate | 45.5% | Fine for a 2R-payoff system |
| Avg win / Avg loss (R) | 1.90 / 0.95 | Payoff 2.00 : 1 — healthy |
| **Expectancy per trade** | **+0.345 R** | **Positive** |
| Rule-break rate | 4 of 22 = **18%** | **Too high** |
| Profit concentration (top 3 winners) | **84% of gross profit** | **Fragile edge** |

## Why HOLD, not SCALE UP

The skill scales up only if **all** of these hold. Yours:

- **Meaningful sample** — 22 trades clears the minimum bar, but only just. Not a strong "yes."
- **Positive expectancy net of costs** — +0.345 R is positive, but the script flags this as *gross*. You still need to confirm these R values are net of commissions, borrow/locate, slippage, and taxes/FX. A +0.345R gross edge can evaporate net of costs on small-account momentum trading.
- **Rule-break rate low and falling** — **FAILS.** 18% is not low, and it is not falling. Your four breaks land on Feb 5, 7, 8, and 10 — spread across the whole window, including the most recent days. The deviations are exactly the dangerous kind: `oversized`, `chased-extended`, `moved-stop`, and `no-catalyst`, several tagged `urge-to-make-it-back`. Adding size on top of unresolved discipline leaks just makes the leaks more expensive.
- **Concentration / edge robustness** — **FAILS.** 84% of your gross profit (R) comes from just 3 of your 10 winners. The sizer explicitly flags this: the edge leans on a few lucky trades — treat expectancy as fragile and do not scale. Strip those 3 trades and the week is roughly flat-to-negative.

Two hard conditions broken means the answer is not "size up." It is not "size down" either — there's no loss streak or regime change here, and expectancy is positive. So the verdict is **HOLD at current size.**

## What earns the size-up next

1. **Cut the rule-break rate toward ~0%.** The breaks, not the market, are your current ceiling. Treat any urge to deviate (oversizing, chasing, moving stops, no-catalyst entries) as a signal to defer to the plan — never as an input.
2. **Confirm expectancy is net of costs.** Re-run with R values after commissions, borrow, slippage, taxes/FX. If it stays positive, good.
3. **Broaden the base.** Build a bigger sample where profit isn't carried by 3 trades. When the top-3 concentration drops and expectancy holds across more winners, the edge is robust enough to lean on.

Then re-audit. Growth is a consequence of consistency, never a substitute for it.

---
*Scope: process only — not financial advice, no buy/sell calls, no price predictions. Correct process is necessary, not sufficient: most day traders lose net of costs.*
