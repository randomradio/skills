# TradingJournal — Notion 配置

> 捕获 / 反思层（capture & reflection）。**UTA 存硬锚点**（account / symbol / order·commit hash / status / timestamp），**Notion 存人的那一层**（thesis、emotion、mistake、lesson、follow-up）。无图表、无绩效统计 —— 只是结构化记忆。数字仍留在 CSV / UTA，供 `weekly-audit` 计算。

> **隐私：** 真实的 Notion 页面/数据库 ID 不入库。它们在 skill 首次运行时解析得到，只写入运行时配置 `~/.config/trading-journal/notion.json`（在仓库之外）。下文一律用占位符。

## 1. 缓存配置（运行时状态）

skill 启动时读取此文件；存在就直接用，缺失才去 Notion 解析并重写。**ID 不写死在 skill 里。**

**路径：** `~/.config/trading-journal/notion.json`

```json
{
  "hub_page_id": "<hub_page_id>",
  "hub_url": "https://app.notion.com/p/<hub_page_id>",
  "trade_threads": {
    "db_url": "https://app.notion.com/p/<trade_threads_db_id>",
    "data_source_id": "<trade_threads_data_source_id>"
  },
  "trading_notes": {
    "db_url": "https://app.notion.com/p/<trading_notes_db_id>",
    "data_source_id": "<trading_notes_data_source_id>"
  },
  "resolved_at": "YYYY-MM-DD"
}
```

## 2. 解析逻辑（首次运行 / 缓存缺失）
1. `search` 顶层标题为 **TradingJournal** 的页面，没有就创建。
2. `fetch` hub，按标题找子数据库 **Trade Threads** 与 **Trading Notes**。
3. 缺哪个建哪个 —— **先建 Trade Threads**（Trading Notes 的关系指向它）。
4. 写入上面的配置文件。

只有配置缺失或写入 404（库被删/移动）时才重新解析一次并重写配置；正常运行不再搜索。

## 3. 结构总览

```
TradingJournal  (顶层 hub)
├── Trade Threads   一个交易想法/持仓叙事 = 一页
└── Trading Notes   一个想法/决策/复盘/教训 = 一页
        └── Trade Thread 关系 ──▶ Trade Threads（双向，回链 "Notes"）
```

| 实体 | 类型 | 标识（占位） |
|---|---|---|
| TradingJournal | page | `<hub_page_id>` |
| Trade Threads | database | ds `<trade_threads_data_source_id>` |
| Trading Notes | database | ds `<trading_notes_data_source_id>` |

## 4. 数据库：Trade Threads

一个交易想法 / 持仓叙事一页（不必是一次完整的 round-trip）。

| 属性 | 类型 | 选项 / 说明 |
|---|---|---|
| `Thread` | **title** | 人类可读标题，如 "GENI · 2026-06-23 · gap-and-go" |
| `Symbol` | text | |
| `Account` | text | 账户集固定后可在 UI 改成 Select |
| `Direction` | select | `long`(green) · `short`(red) |
| `State` | select | `Watching`(gray) · `Planned`(blue) · `Open`(yellow) · `Closed`(green) · `Abandoned`(default) |
| `Started At` | date | |
| `Closed At` | date | |
| `Primary Setup` | select | gap-and-go · bull-flag breakout · short-into-spike · vwap reclaim · support reclaim |
| `Final Lesson` | text | |
| `Notes` | relation（回链） | 自动 ◀── Trading Notes 的 `Trade Thread` |

## 5. 数据库：Trading Notes

一个想法 / 决策 / 复盘 / 教训一页；锚到 UTA，链接到所属 thread。

| 属性 | 类型 | 选项 / 说明 |
|---|---|---|
| `Note` | **title** | |
| `Date` | date | |
| `Type` | select | `Pre-trade` · `During trade` · `Post-trade` · `Daily review` · `Rule` · `Lesson` |
| `Account` | text | |
| `Symbol` | text | |
| `Direction` | select | `long` · `short` |
| `Status` | select | `Draft` · `Needs review` · `Reviewed` |
| `Tags` | multi-select | `setup` · `mistake` · `emotion` · `market regime` |
| `UTA Ref` | text | commit hash / order id / snapshot ts / position id |
| `Trade Thread` | relation ▶ | Trade Threads（双向，回链 "Notes"） |

## 6. 捕获时机（capture moments）

| 时机 | 动作 |
|---|---|
| 挂单 / stage order | 建 **Pre-trade** note（Context · Thesis · Invalidation · Emotional State），链到该 symbol 的开放 thread（无则建） |
| 提交 / commit | 追加 **UTA commit hash** + 最终意图 |
| UTA 同步看到 filled / cancelled / rejected | 追加一条**事实性**记录，不做解读 |
| 平仓 / 放弃 | 建 **Post-trade** note（Execution · Mistake/Rule · Reflection）；设 thread 的 `State` + `Final Lesson`；**数字写进 CSV** |
| 收盘 / EOD | 建 **Daily review** note，链接当天的 notes；用 CSV 按 **R** 汇总当天 |

## 7. Note 正文模板

```
## Context           盘面发生了什么？
## Thesis            这笔交易为什么成立？
## Invalidation      什么会证明我错了？
## Execution Notes   实际发生了什么？
## Emotional State   Calm / rushed / fearful / revenge / patient / bored
## Mistake or Rule   有没有按计划执行？
## Reflection        未来的我该记住什么？
```

## 8. 写入属性的坑（每次捕获都要注意）

- 日期：用展开键 `date:Date:start` / `date:Started At:start` = `YYYY-MM-DD`。
- `Tags`：JSON 数组，如 `["setup","emotion"]`。
- `Trade Thread`：thread 页面 URL 的 JSON 数组，如 `["https://app.notion.com/p/<id>"]`。
- `Type` / `Status` / `Direction` / `State` / `Primary Setup`：传精确的选项字符串。
- `Account` 现为 text；账户集固定后改成 Select 方便筛选。

## 9. 示例页

首次创建时会生成一对 `[EXAMPLE]` thread + 链接的 Pre-trade note 作为样例（在你自己的 Notion 里，可随时删除）。
