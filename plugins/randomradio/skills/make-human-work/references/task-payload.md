# Human Task Payload

Use this schema whenever an agent needs asynchronous human intervention.

## Trigger Classification

Create a human task when the next meaningful step needs one of these:

| Trigger | Examples | Required payload detail |
|---|---|---|
| Access | OAuth, API key, 2FA, private repo, billing console | Name the access scope, never ask for the secret in Notion |
| Decision | Product direction, copy, design option, tradeoff | Provide options and a default recommendation |
| Approval | Destructive command, paid action, privacy-sensitive operation | State exact command/action and risk |
| External action | Click UI, approve email, upload file, change SaaS setting | Step-by-step action and success signal |
| Missing context | Requirement ambiguity that blocks implementation | Ask one minimal question |
| Human verification | User must inspect visual/UI/result manually | Include URL/path and what to verify |

Do not create a human task for internal agent todos, routine code work, ordinary
test failures, or status updates.

## Property Payload

Use properties only when the database supports them:

| Field | Value |
|---|---|
| Name | Imperative task title |
| Status | `Inbox` or configured default |
| Priority | `P2` unless risk or urgency justifies another value |
| Assignee | Configured default assignee |
| Agent | Current agent/platform name, if known |
| Repo | Current repo name or cwd |
| Branch | Current git branch, if known |
| Thread | Thread URL/ID, if known |
| Due | Only set when the user provided a date |

## Body Template

````markdown
## Requested Action

[One exact thing the human should do.]

## Why This Is Needed

[What is blocked, risky, or outside the agent environment.]

## Acceptance Criteria

- [ ] [Concrete completion signal]

## Context

- Agent: [agent/platform/model if known]
- Repo/CWD: [path]
- Branch: [branch]
- Worktree: [path if different]
- Related files/commands/URLs: [list]
- Error or decision point: [short excerpt]

## Options

1. [Option A] -- [tradeoff]
2. [Option B] -- [tradeoff]

Recommended default: [option or action]

## Return To Agent

Thread: [thread URL/ID if available]

Resume prompt:

```text
I completed the Notion task "[title]".
Result: [paste decision, confirmation, link, or completed action here]
Please resume from: [repo/cwd, branch, blocked step].
```
````

Omit `Options` when the task is not a decision.

## Title Rules

Good titles:

- `Approve the production deploy for billing webhook fix`
- `Choose copy direction for onboarding empty state`
- `Grant Notion integration access to the Tasks database`

Poor titles:

- `Need help`
- `Question`
- `Blocked`

## Priority Rules

| Priority | Use when |
|---|---|
| `P0` | The agent is fully blocked and the work is urgent or production-impacting |
| `P1` | The agent is blocked on a major deliverable |
| `P2` | Default for normal human handoffs |
| `P3` | Nice-to-have review or non-blocking follow-up |

## Return Path Rules

Always include a copy-paste resume prompt. If the platform exposes a thread URL,
thread ID, worktree ID, run ID, or branch, include it too. If none is available,
the resume prompt plus repo/cwd/branch is the return path.

Do not invent a URL scheme. Use only links or IDs actually exposed by the
runtime.
