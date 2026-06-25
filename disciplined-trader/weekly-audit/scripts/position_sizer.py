#!/usr/bin/env python3
"""
position_sizer.py — risk math for the momentum-trade-discipline skill.

Governs PROCESS only. Not financial advice. No buy/sell recommendations.

Subcommands:
  plan        Size a single trade and run the GO/NO-GO checks.
  expectancy  Compute expectancy (in R) from a results sample or a journal CSV.

Examples:
  python position_sizer.py plan --account 5000 --risk 0.01 --entry 4.00 --stop 3.80 --target 4.50
  python position_sizer.py plan --account 5000 --risk 0.01 --entry 4.00 --stop 4.20 --target 3.40 --side short
  python position_sizer.py expectancy --wins 14 --losses 6 --avg-win-r 2.1 --avg-loss-r 1.0
  python position_sizer.py expectancy --journal trade_journal_template.csv
"""
import argparse, csv, sys

MIN_RR = 2.0          # Gate 3 threshold
DAILY_STOP_R = 3.0    # daily max loss in R
RISK_CAP = 0.02       # hard cap on per-trade risk fraction


def fmt(x): return f"{x:,.2f}"


def plan(a):
    side = a.side.lower()
    if side not in ("long", "short"):
        sys.exit("side must be long or short")
    if a.risk <= 0 or a.risk > RISK_CAP:
        print(f"WARNING: risk per trade {a.risk:.2%} exceeds the {RISK_CAP:.0%} hard cap — "
              f"clamping for the calc. Smaller is safer on a small account.")
    risk_frac = min(a.risk, RISK_CAP)

    per_share_risk = (a.entry - a.stop) if side == "long" else (a.stop - a.entry)
    per_share_reward = (a.target - a.entry) if side == "long" else (a.entry - a.target)

    if per_share_risk <= 0:
        sys.exit("Invalid stop: for a long the stop must be BELOW entry; for a short, ABOVE entry. "
                 "This means your invalidation level is on the wrong side — fix the plan (Gate 3).")

    risk_dollars = a.account * risk_frac
    shares = int(risk_dollars / per_share_risk + 1e-9)  # floor, guarding float error (50/0.20 -> 250)
    rr = (per_share_reward / per_share_risk) if per_share_risk else 0.0
    position_value = shares * a.entry
    daily_max = DAILY_STOP_R * risk_dollars

    print("\n=== TRADE PLAN ===")
    print(f"Side                 : {side}")
    print(f"Account              : ${fmt(a.account)}")
    print(f"Risk per trade       : {risk_frac:.2%}  (${fmt(risk_dollars)})")
    print(f"Entry / Stop / Target: {a.entry} / {a.stop} / {a.target}")
    print(f"Per-share risk       : ${fmt(per_share_risk)}")
    print(f"Position size        : {shares:,} shares  (~${fmt(position_value)} exposure)")
    print(f"Reward : Risk        : {rr:.2f} : 1")
    print(f"Daily max loss (3R)  : ${fmt(daily_max)}  -> hit this, stop for the day")

    print("\n=== GATE 3 (Plan) VERDICT ===")
    verdict_go = True
    if rr < MIN_RR:
        print(f"NO-GO: R:R {rr:.2f} is below the {MIN_RR:.1f} minimum. Move the target, tighten the "
              f"stop to a valid level, or skip. Do NOT loosen risk to force it.")
        verdict_go = False
    else:
        print(f"R:R {rr:.2f} >= {MIN_RR:.1f}  OK")
    if shares <= 0:
        print("NO-GO: computed size is 0 — stop is too far for this account/risk. Smaller idea or skip.")
        verdict_go = False
    if position_value > a.account * 4:
        print(f"CAUTION: exposure ~${fmt(position_value)} implies heavy leverage vs a ${fmt(a.account)} "
              f"account. Confirm your broker/PDT reality and that liquidity supports this size.")
    print(f"\n>>> {'GO (plan math passes — still clear Gates 1,2,4,5)' if verdict_go else 'NO-GO'} <<<")
    print("Reminder: gross math here ignores commissions, borrow/locate, slippage, taxes/FX (Gate 5).\n")


def _expectancy(win, loss, awr, alr):
    total = win + loss
    if total == 0:
        return None
    wp, lp = win / total, loss / total
    exp_r = wp * awr - lp * alr
    return wp, lp, exp_r


def expectancy(a):
    if a.journal:
        wins = losses = 0
        wr_sum = lr_sum = 0.0
        breaks = 0
        rows = 0
        win_rs = []  # per-trade positive R, for profit-concentration
        with open(a.journal, newline="") as f:
            for row in csv.DictReader(f):
                val = (row.get("realized_R") or "").strip()
                if not val:
                    continue
                try:
                    r = float(val)
                except ValueError:
                    continue
                rows += 1
                if (row.get("followed_plan") or "").strip().upper() == "N":
                    breaks += 1
                if r >= 0:
                    wins += 1; wr_sum += r; win_rs.append(r)
                else:
                    losses += 1; lr_sum += -r
        if rows == 0:
            sys.exit("No usable rows with a numeric 'realized_R' found in the journal yet.")
        awr = wr_sum / wins if wins else 0.0
        alr = lr_sum / losses if losses else 0.0
        res = _expectancy(wins, losses, awr, alr)
        print("\n=== JOURNAL EXPECTANCY ===")
        print(f"Sample (with realized_R) : {rows} trades")
        print(f"Rule-breaks logged       : {breaks}  ({breaks/rows:.0%} of sample)")
        # Profit concentration: is the edge real or carried by a few lucky trades?
        winners = sorted((x for x in win_rs if x > 0), reverse=True)
        gross_profit_r = sum(winners)
        if gross_profit_r > 0:
            conc = sum(winners[:3]) / gross_profit_r
            print(f"Profit concentration     : top 3 winners = {conc:.0%} of gross profit (R) "
                  f"[{min(3, len(winners))} of {len(winners)} winning trades]")
            if conc >= 0.80 and len(winners) >= 4:
                print("  ^ High: the edge leans on a few trades — treat expectancy as fragile, do not scale.")
        else:
            print("Profit concentration     : n/a (no winning trades in sample yet)")
    else:
        if a.wins is None or a.losses is None:
            sys.exit("Provide --journal OR all of --wins --losses --avg-win-r --avg-loss-r")
        awr, alr = a.avg_win_r, a.avg_loss_r
        res = _expectancy(a.wins, a.losses, awr, alr)
        print("\n=== EXPECTANCY ===")

    wp, lp, exp_r = res
    print(f"Win rate                 : {wp:.1%}")
    print(f"Avg win  (R)             : {awr:.2f}")
    print(f"Avg loss (R)             : {alr:.2f}")
    print(f"Payoff (avg win/avg loss): {(awr/alr):.2f}" if alr else "Payoff: n/a")
    print(f"Expectancy per trade (R) : {exp_r:+.3f}")
    if exp_r > 0:
        print(">>> POSITIVE expectancy (net of costs?). Edge looks real on this sample — "
              "scale size only per the Weekly Audit rules.")
    else:
        print(">>> NON-POSITIVE expectancy. Do NOT add size or volume. Tighten setup selection / "
              "risk, or stand down and study. More trades here = more loss.")
    print("Note: confirm these R values are NET of commissions, borrow, slippage, taxes/FX.\n")


def main():
    p = argparse.ArgumentParser(description="Risk math for momentum-trade-discipline (process only; not advice).")
    sub = p.add_subparsers(dest="cmd", required=True)

    pp = sub.add_parser("plan", help="Size a trade and run GO/NO-GO checks.")
    pp.add_argument("--account", type=float, required=True)
    pp.add_argument("--risk", type=float, default=0.01, help="risk fraction per trade (default 0.01 = 1%%)")
    pp.add_argument("--entry", type=float, required=True)
    pp.add_argument("--stop", type=float, required=True)
    pp.add_argument("--target", type=float, required=True)
    pp.add_argument("--side", default="long", help="long or short")
    pp.set_defaults(func=plan)

    pe = sub.add_parser("expectancy", help="Expectancy from a sample or a journal CSV.")
    pe.add_argument("--journal", help="path to trade journal CSV (uses realized_R, followed_plan)")
    pe.add_argument("--wins", type=int)
    pe.add_argument("--losses", type=int)
    pe.add_argument("--avg-win-r", dest="avg_win_r", type=float, default=0.0)
    pe.add_argument("--avg-loss-r", dest="avg_loss_r", type=float, default=0.0)
    pe.set_defaults(func=expectancy)

    a = p.parse_args()
    a.func(a)


if __name__ == "__main__":
    main()
