# Make Human Work

`rr:make-human-work` lets long-running agents hand human intervention work to a
configured Notion task database.

Use it when an agent needs access, approval, a product/design decision, an
external action, or a human verification step. Each task includes a resume prompt
so the human can return to the original agent thread with the answer or
confirmation.

Setup stores local, non-secret configuration in
`~/.codex/make-human-work.env`. Prefer the connected Notion app for writes;
fall back to `NOTION_TOKEN` only when app tools are unavailable.
