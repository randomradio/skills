# Notion target — resolution, config, and schema

The two databases live under a top-level **TradingJournal** hub. Their IDs are **never hard-coded in
the skill** — resolve them once, cache them, and reuse them. This keeps the skill portable and lets it
self-heal if a database is moved or recreated.

## Cached config (runtime state)
Path: **`~/.config/trading-journal/notion.json`**. Written on the first resolve; read on every run after.

```json
{
  "hub_page_id": "…",
  "hub_url": "https://app.notion.com/p/…",
  "trade_threads": { "db_url": "https://app.notion.com/p/…", "data_source_id": "…" },
  "trading_notes": { "db_url": "https://app.notion.com/p/…", "data_source_id": "…" },
  "resolved_at": "YYYY-MM-DD"
}
```

## Resolution (first run, or cache miss)
1. `search` for a top-level page titled **TradingJournal**; create it if absent.
2. `fetch` the hub; locate child databases **Trade Threads** and **Trading Notes** by title.
3. Create whichever is missing — **Trade Threads first**, because Trading Notes' relation points at it.
4. Write the config above.

Re-resolve **only** when the config is missing/incomplete, or a later write returns 404 (DB deleted or
moved) — then re-resolve once and rewrite the config. Never search on a normal run.

## Trade Threads — schema
```
CREATE TABLE ("Thread" TITLE, "Symbol" RICH_TEXT, "Account" RICH_TEXT,
  "Direction" SELECT('long':green,'short':red),
  "State" SELECT('Watching':gray,'Planned':blue,'Open':yellow,'Closed':green,'Abandoned':default),
  "Started At" DATE, "Closed At" DATE,
  "Primary Setup" SELECT('gap-and-go':blue,'bull-flag breakout':green,'short-into-spike':red,'vwap reclaim':purple,'support reclaim':orange),
  "Final Lesson" RICH_TEXT)
```

## Trading Notes — schema (create AFTER Trade Threads; substitute its data_source_id)
```
CREATE TABLE ("Note" TITLE, "Date" DATE,
  "Type" SELECT('Pre-trade':blue,'During trade':yellow,'Post-trade':green,'Daily review':purple,'Rule':orange,'Lesson':pink),
  "Account" RICH_TEXT, "Symbol" RICH_TEXT, "Direction" SELECT('long':green,'short':red),
  "Status" SELECT('Draft':gray,'Needs review':yellow,'Reviewed':green),
  "Tags" MULTI_SELECT('setup':blue,'mistake':red,'emotion':purple,'market regime':orange),
  "UTA Ref" RICH_TEXT,
  "Trade Thread" RELATION('<TRADE_THREADS_DATA_SOURCE_ID>', DUAL 'Notes'))
```

## Property-write quirks (used on every capture)
- Dates: set `date:Date:start` / `date:Started At:start` = `YYYY-MM-DD`.
- `Tags`: JSON array, e.g. `["setup","emotion"]`.
- `Trade Thread`: JSON array of the thread's page URL(s).
- `Type` / `Status` / `Direction` / `State` / `Primary Setup`: the exact option string.
- `Account` is text (convert to a Select in the UI once your account set is fixed).
