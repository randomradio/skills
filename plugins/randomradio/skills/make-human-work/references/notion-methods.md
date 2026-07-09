# Notion Write Methods

Use the richest available method and degrade gracefully.

## Native Notion Tool Path

Prefer the connected Notion app when it is available.

1. If Notion tools are already visible, use them directly.
2. If `tool_search` is available but Notion tools are not visible, search once
   for `Notion notion-create-pages fetch search`.
3. If a Notion MCP call returns `Tool <name> not found`, treat that tool as
   unavailable for the rest of the current task. Do not retry the same missing
   tool with different arguments.
4. Use `Notion:search` only with literal query strings and `filters: {}` when no
   filters are needed.
5. Pass only Notion page, database, or data-source URLs/IDs to `Notion:fetch`.
6. Create database-backed pages with an explicit parent and a `pages` array.

Typical flow:

```text
Notion:fetch(database URL or database ID)
-> extract collection://... data source ID and property schema
-> Notion:notion-create-pages(parent: {type: "data_source_id", data_source_id}, pages: [...])
```

When updating an existing task, fetch it first and use the update mode supported
by the current Notion tool schema. If the tool requires both `properties` and
`content_updates`, pass empty objects/arrays for the unused side.

## REST API Fallback

Use this only when native Notion tools are unavailable and `NOTION_TOKEN` is set.

Create page skeleton:

```bash
curl -sS https://api.notion.com/v1/pages \
  -H "Authorization: Bearer $NOTION_TOKEN" \
  -H "Notion-Version: 2022-06-28" \
  -H "Content-Type: application/json" \
  --data @payload.json
```

Minimal `payload.json` shape:

```json
{
  "parent": {"database_id": "DATABASE_ID"},
  "properties": {
    "Name": {
      "title": [
        {"text": {"content": "Task title"}}
      ]
    }
  },
  "children": [
    {
      "object": "block",
      "type": "heading_2",
      "heading_2": {
        "rich_text": [{"type": "text", "text": {"content": "Requested Action"}}]
      }
    },
    {
      "object": "block",
      "type": "paragraph",
      "paragraph": {
        "rich_text": [{"type": "text", "text": {"content": "Task body excerpt"}}]
      }
    }
  ]
}
```

If property validation fails, retry once with title-only properties and the full
payload in `children`.

## Duplicate Handling

Before creating a task, search for an open task with the same:

- normalized title,
- repo/cwd,
- branch, and
- blocked step or requested action.

If a likely duplicate exists, update the existing task body/status instead of
creating a new page. When search is unavailable, prefer creating the task over
dropping the handoff.

## Local Fallback

When no Notion write path is available:

1. If the workspace is writable, create `.context/human-tasks/`.
2. Write one markdown file per task:

```text
.context/human-tasks/YYYYMMDD-HHMMSS-task-slug.md
```

3. Include the full body template from `task-payload.md`.
4. Report the file path and the missing Notion capability.

If the workspace is not writable, return the full payload inline and ask the user
to connect Notion or provide `NOTION_TOKEN`.

## Safety

- Do not put secrets, tokens, passwords, or private key material into Notion.
- Ask the user to perform secret entry in the relevant system and report only
  that it was completed.
- Include minimal necessary logs. Redact credentials and personal data.
- Do not mark a Notion task done until the human result has been incorporated or
  the original work no longer needs it.
