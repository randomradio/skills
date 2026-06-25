---
name: trade-journal
description: >-
  Atomic capture/reflection layer for trading, plus same-day numeric logging. Use this skill WHENEVER
  the user records, reflects on, or reviews a trade — "log this trade", "journal", "pre-trade note",
  "thesis on this", "review my day", "what did I learn", "track my trades" — and at natural capture
  moments: staging an order, committing/approving, a fill/cancel/reject, closing/abandoning a position,
  and end of day. It writes the HUMAN layer (thesis, emotion, mistake, lesson, follow-up) to Notion
  (Trade Threads + Trading Notes, anchored to UTA refs) and keeps the hard NUMBERS (realized_R,
  followed_plan, rule_breaks) in assets/trade_journal_template.csv so weekly-audit can compute
  expectancy. No charts or performance stats in Notion — structured memory only. Process only.
---

# Trade Journal  (atomic) — capture & reflection

**Purpose:** You cannot trust or improve an edge you do not measure — but the measurement has two
layers, and they must not be mixed. UTA holds the hard anchors (account, symbol, order/commit hash,
status, timestamp). This skill captures the rest.

## Two layers — keep them separate
- **Numbers → CSV.** `assets/trade_journal_template.csv` (copy it to your own file). Log `realized_R`,
  `followed_plan`, `rule_breaks`. This is the substrate `weekly-audit` reads for expectancy. Keep it.
- **Reflection → Notion.** Thesis, emotion, mistake, lesson, follow-up. **No charts, no stats** here —
  just structured memory. Stats live in the CSV / UTA, not in Notion.

## Notion target — resolve once on startup, then reuse
The reflection layer lives in two databases — **Trade Threads** (one page per trade idea / position
narrative; `State`: Watching → Planned → Open → Closed / Abandoned — a trade is a *story*, not a forced
round-trip) and **Trading Notes** (one page per thought / decision / review / lesson, linked by the
`Trade Thread` relation) — under a top-level **TradingJournal** hub.

**Do not hard-code the database IDs.** On startup, read the cached config at
**`~/.config/trading-journal/notion.json`**:
- **Present** → use its IDs directly; do not search Notion again.
- **Missing/incomplete** → resolve once (find the TradingJournal hub and the two databases by title,
  creating any that are absent), then write the config. See `references/notion-schema.md` for the
  resolution steps, the exact database schema, and the config shape.
- If a later write 404s (database moved/deleted), re-resolve once and rewrite the config.

Write via the Notion MCP (`create-pages` / `update-page`). If Notion isn't connected, fall back to the
CSV `notes`/`deviation_signal` columns and tell the user the reflection layer was skipped.

## Capture moments — create or update at each natural point
1. **Stage an order** → create a **Pre-trade** note (`Status` = Needs review): Context, Thesis,
   Invalidation, Emotional State. Link it to the symbol's open **Trade Thread** (create one if none).
   Put the staged order id in `UTA Ref`.
2. **Commit / approve** → append the **UTA commit hash** + final intent to that note.
3. **UTA sync sees filled / cancelled / rejected** → append a short, *factual* line. No interpretation.
4. **Position closed / abandoned** → create a **Post-trade** note: Execution Notes, Mistake or Rule,
   Reflection. Set the thread's `State` and `Final Lesson`. **Also log the numbers to the CSV.**
5. **End of day** → create a **Daily review** note linking that day's notes; sum the day in **R** from
   the CSV (keeps ego and account size out of the assessment).

## Note body — always this template
```
## Context           What was happening in the market?
## Thesis            Why did this trade make sense?
## Invalidation      What would prove me wrong?
## Execution Notes   What actually happened?
## Emotional State   Calm / rushed / fearful / revenge / patient / bored
## Mistake or Rule   Did I follow the plan?
## Reflection        What should future-me remember?
```

## Writing a note — property cheatsheet (Notion quirks)
- Title property is `Note` (threads use `Thread`).
- Date → set `date:Date:start` = `YYYY-MM-DD` (threads: `date:Started At:start`).
- `Type` (Pre-trade · During trade · Post-trade · Daily review · Rule · Lesson), `Status`
  (Draft · Needs review · Reviewed), `Direction` (long · short) → use the exact option string.
- `Tags` is multi-select → JSON array, e.g. `["setup","emotion"]` (options: setup, mistake, emotion,
  market regime).
- `UTA Ref` → text: order id / commit hash / snapshot timestamp / position id.
- `Trade Thread` → JSON array of the thread's page URL(s), e.g. `["https://app.notion.com/p/<id>"]`.
- **Find-or-create the thread:** query Trade Threads for the `Symbol` with `State` in
  (Watching, Planned, Open); reuse it, else create one. One story per thread, not one per fill.

## Same-day review (5 min)
- Tag each rule-break (CSV `rule_breaks`); write one sentence on how to prevent it.
- Sum the day in **R**, not dollars.

**Next (weekly):** `weekly-audit` (reads the CSV).
---

*Scope: process only — not financial advice, no buy/sell calls, no price predictions. Trading is treated as a logical, rule-based system; an urge to deviate is a signal to defer to the plan, never an input. Correct process is necessary, not sufficient: most day traders lose net of costs.*
