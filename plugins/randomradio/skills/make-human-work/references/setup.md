# Make Human Work Setup

This reference defines the one-time setup for routing agent-to-human tasks into
a Notion database.

## Configuration File

Store local, non-secret settings in:

```bash
~/.codex/make-human-work.env
```

Recommended template:

```bash
MAKE_HUMAN_WORK_NOTION_DATABASE_ID=
MAKE_HUMAN_WORK_NOTION_DATABASE_URL=
MAKE_HUMAN_WORK_NOTION_DATA_SOURCE_ID=
MAKE_HUMAN_WORK_DEFAULT_ASSIGNEE=
MAKE_HUMAN_WORK_DEFAULT_PRIORITY=P2
MAKE_HUMAN_WORK_DEFAULT_STATUS=Inbox
MAKE_HUMAN_WORK_DONE_STATUS=Done
MAKE_HUMAN_WORK_FIELD_TITLE=Name
MAKE_HUMAN_WORK_FIELD_STATUS=Status
MAKE_HUMAN_WORK_FIELD_PRIORITY=Priority
MAKE_HUMAN_WORK_FIELD_ASSIGNEE=Assignee
MAKE_HUMAN_WORK_FIELD_AGENT=Agent
MAKE_HUMAN_WORK_FIELD_REPO=Repo
MAKE_HUMAN_WORK_FIELD_BRANCH=Branch
MAKE_HUMAN_WORK_FIELD_THREAD=Thread
MAKE_HUMAN_WORK_FIELD_DUE=Due
```

Secrets do not belong in this file unless the user explicitly accepts that local
risk. Prefer the Notion app OAuth connection. If the app is unavailable, use a
shell secret named `NOTION_TOKEN`.

For CloudPy, Codex Cloud, or any remote agent runtime, set the same
`MAKE_HUMAN_WORK_*` variables in that runtime's environment or secret/config
store. Do not assume a cloud agent can read the local `~/.codex` file.

If the previous draft variables `HUMAN_TASKS_*` already exist, treat them as a
compatibility fallback. New setup should use `MAKE_HUMAN_WORK_*`.

## Recommended Database Schema

The skill can work with only a title property because the page body contains the
full task payload. These optional properties make the database easier to scan:

| Property | Type | Default name | Required? |
|---|---|---|---|
| Title | Title | `Name` | Yes |
| Status | Select | `Status` | No |
| Priority | Select | `Priority` | No |
| Assignee | Person or text | `Assignee` | No |
| Agent | Text | `Agent` | No |
| Repo | Text | `Repo` | No |
| Branch | Text | `Branch` | No |
| Thread | URL or text | `Thread` | No |
| Due | Date | `Due` | No |

Suggested select values:

| Field | Values |
|---|---|
| Status | `Inbox`, `Waiting on Human`, `In Progress`, `Done`, `Needs follow-up` |
| Priority | `P0`, `P1`, `P2`, `P3` |

## Setup Workflow

1. Ask the user for a Notion task database URL or ID.
2. If Notion tools are available, fetch the database and capture the data source
   ID if one is returned.
3. Compare the returned properties with the recommended schema.
4. If a recommended property is missing, do not require schema migration. Store
   that field in the page body instead.
5. Write the configuration file with the database identity and any field-name
   overrides.
6. For cloud agents, mirror the same settings into the cloud runtime config.
7. Create a dry-run task titled `Test human handoff from agent`.
8. Mark the dry-run task `Done` if status updates are supported.

## Field Mapping Rules

Use the configured field name only if that property exists in the fetched
database. If it does not exist, omit it from `properties` and include the value in
the page body.

Never invent Notion property types. If the fetched schema says `Priority` is
text, write text. If it says select, write a select value. If unsure, omit the
property and use the body.

## Setup Success Criteria

Setup is complete only when:

- The destination database ID, URL, or data source ID is stored locally.
- The agent has a working Notion write path or has documented the fallback.
- A dry-run task was created or a precise failure payload was produced.
- The user knows where future human tasks will appear.

## Troubleshooting

- **Notion tool missing**: Ask the user to connect the Notion app for the current
  Codex/plugin session, then retry in a fresh session if tools still do not
  appear.
- **Database not found**: Confirm the integration has access to the database and
  that the URL/ID is from the database, not a view-only page.
- **Property validation fails**: Fetch the database schema again and only set
  confirmed fields. Put the rest in the body.
- **REST API 401/403**: `NOTION_TOKEN` is missing, invalid, or not shared with
  the database.
