---
name: rr:make-human-work
description: >
  Make Human Work by creating Notion tasks for human intervention during
  long-running Codex, CloudPy, Claude, or agent execution. Use when an agent
  needs the user to grant access, answer a blocking question, make a
  product/design decision, perform an external action, approve a risky step,
  complete a manual checklist item, "send this to me as a task", or "make human
  work". Also trigger for async human handoff, human-in-the-loop blockers,
  return-to-agent links, Notion task list setup, and resuming an agent after the
  user completes a task.
argument-hint: "[setup | create task | resume task | blocking question/context]"
---

# Make Human Work

Route real human-intervention work from long-running agents into a configured
Notion task database, with enough context for the human to act and return to the
same agent session.

<human_task_input> #$ARGUMENTS </human_task_input>

## Step 1: Detect Runtime and Configuration

Check local configuration, Notion access, and fallback paths before creating or
resuming any task.

**Environment status:**

```bash
!`bash -lc 'set -a; test -f "$HOME/.codex/make-human-work.env" && source "$HOME/.codex/make-human-work.env"; test -f "$HOME/.codex/human-notion-tasks.env" && source "$HOME/.codex/human-notion-tasks.env"; set +a; if [[ -n "${MAKE_HUMAN_WORK_NOTION_DATABASE_ID:-}${MAKE_HUMAN_WORK_NOTION_DATA_SOURCE_ID:-}${MAKE_HUMAN_WORK_NOTION_DATABASE_URL:-}${HUMAN_TASKS_NOTION_DATABASE_ID:-}${HUMAN_TASKS_NOTION_DATA_SOURCE_ID:-}${HUMAN_TASKS_NOTION_DATABASE_URL:-}" ]]; then echo "MAKE_HUMAN_WORK_CONFIG_READY"; else echo "MAKE_HUMAN_WORK_CONFIG_MISSING"; fi' 2>/dev/null || echo "MAKE_HUMAN_WORK_CONFIG_CHECK_FAILED"`
```

```bash
!`bash -lc 'if [[ -n "${NOTION_TOKEN:-}" ]]; then echo "NOTION_TOKEN_SET"; else echo "NOTION_TOKEN_NOT_SET"; fi' 2>/dev/null || echo "NOTION_TOKEN_CHECK_FAILED"`
```

```bash
!`command -v codex 2>/dev/null && codex --version 2>/dev/null || echo "CODEX_CLI_MISSING"`
```

**Decision tree:**

1. If `<human_task_input>` asks for setup, follow Step 2 before any task write.
2. If config is ready and Notion tools are visible, use the native Notion path.
3. If Notion tools are not visible but `tool_search` exists, search for Notion
   tools once; if found, use the native Notion path.
4. If no Notion tools exist but `NOTION_TOKEN_SET`, use the Notion API fallback.
5. If neither Notion path is available, create a local fallback task payload and
   tell the user what must be connected before automatic writes can work.

Read `references/setup.md` for setup details and `references/notion-methods.md`
for the native/API/local write paths.

## Step 2: Set Up the Task Destination

Run this step when the user asks to set up the skill or Step 1 reports missing
configuration.

**Required input:**

| Parameter | Default if missing | Rationale |
|---|---|---|
| Notion task database ID or URL | Ask once | The destination cannot be inferred safely |
| Data source ID | Fetch from the database when Notion tools exist | Notion create calls often need `collection://...` |
| Field mapping | Use default mapping in `references/setup.md` | Allows existing databases with different property names |
| Default assignee | Current user | Human tasks are usually for the requester |
| Default priority | `P2` | Important but not automatically urgent |
| Default status for new tasks | `Inbox` | Keeps triage separate from active work |
| Return method | Resume prompt in task body | Works even when no clickable thread URL exists |

Store non-secret settings in `~/.codex/make-human-work.env`. Do not commit
database IDs, tokens, field maps, or personal workspace settings into the repo.
Use Notion app OAuth when available; otherwise use `NOTION_TOKEN` as a secret in
the local environment. For CloudPy or Codex Cloud agents, set the same
`MAKE_HUMAN_WORK_*` variables in the agent environment or secret/config store
instead of relying on the local file. If the older `HUMAN_TASKS_*` variables
already exist, treat them as a compatibility fallback.

**Setup gate:** Create one dry-run task titled
`Test human handoff from agent`. If Notion write fails, do not pretend setup is
complete; record the exact failing path and fall back to a local payload.

## Step 3: Decide Whether a Human Task Is Warranted

Create a Notion task only for work the agent cannot or should not complete on
its own.

| Situation | Create task? | Notes |
|---|---:|---|
| Missing permission, API key, account access, OAuth, billing, or 2FA | Yes | Include the exact access needed, not the secret |
| Product, design, legal, safety, or business decision | Yes | Present concrete options and default recommendation |
| Destructive, costly, irreversible, or privacy-sensitive action | Yes | Require explicit approval before proceeding |
| External action outside the agent environment | Yes | Examples: click in a browser session, approve email, move a file |
| Ambiguous requirement blocking progress | Yes | Ask the smallest question that unblocks execution |
| Ordinary implementation todo the agent can do | No | Keep it in the local task list |
| Test failure or bug the agent can investigate | No | Debug it directly |
| Progress update with no human action | No | Summarize in the agent thread instead |

If some independent work can continue, create the human task and keep going on
non-blocked units. Stop only when the next meaningful step truly depends on the
human result.

## Step 4: Build the Task Payload

Create one task per human action. Do not bundle unrelated decisions into one
task.

Minimum payload:

1. **Title**: Imperative and specific, under 90 characters.
2. **Requested action**: The exact thing the human must do.
3. **Why now**: What is blocked or risky.
4. **Acceptance criteria**: How the agent will know the task is done.
5. **Context**: Repo, cwd, branch, command, error, links, and relevant files.
6. **Options**: Concrete choices when asking for a decision.
7. **Return to agent**: Thread URL/ID if available, plus a resume prompt.

Use `references/task-payload.md` for the full schema and body template.

**Return-to-agent default:** Always include a copy-paste resume prompt. A
clickable thread link is a bonus, not the only return path.

## Step 5: Write or Update the Notion Task

Use the richest available method from Step 1.

**Native Notion path:**

1. Fetch the configured database or URL.
2. Extract the data source ID and available properties.
3. Map only confirmed properties; put everything else in the page body.
4. Create the task with `Notion:notion-create-pages`.
5. If creating a duplicate for the same blocker, update the existing task
   instead of creating a second one.

**API fallback path:**

1. Use `NOTION_TOKEN` and the configured database ID.
2. Create the page through the Notion REST API.
3. Store unsupported fields in the task body.

**Local fallback path:**

1. Write a markdown payload under `.context/human-tasks/` when the workspace is
   writable.
2. Otherwise, return the full task payload in the agent message.
3. Tell the user that Notion app access or `NOTION_TOKEN` is required for
   automatic database writes.

See `references/notion-methods.md` for exact tool and API patterns.

## Step 6: Resume After Human Completion

Run this step when the user returns with an answer, a completed Notion task, or a
task URL.

1. Fetch the task when Notion access is available; otherwise use the user's
   pasted answer.
2. Extract the human result, decision, credential/action confirmation, or link.
3. Restate what changed and how it unblocks the agent.
4. Continue the original work from the saved context.
5. Update the Notion task status to `Done` or `Needs follow-up` when a write path
   is available.

If the human answer is incomplete, create a follow-up task only when another
async round trip is necessary; otherwise ask directly in the current thread.

## Step 7: Respond to the User

Use this output structure:

1. **Task status**: Created, updated, resumed, setup complete, or fallback only.
2. **Task link or location**: Notion URL when available; local file path or inline
   payload when not.
3. **Human action needed**: One sentence stating what the user must do.
4. **Return path**: Thread link/ID if available and the resume prompt.
5. **Agent next step**: Whether the agent is continuing independent work or is
   blocked until the task is completed.

## Reference Files

- `references/setup.md` -- Configuration file, recommended Notion schema, field
  mapping, and setup checklist.
- `references/task-payload.md` -- Human task trigger rules, payload schema,
  Notion body template, and resume prompt template.
- `references/notion-methods.md` -- Native Notion tool path, REST API fallback,
  duplicate handling, and local fallback.
