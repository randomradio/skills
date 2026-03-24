# OpenAI Long-Horizon Notes (Condensed)

Use this note when building plans for work that cannot finish in a single short interaction.

## Core idea

Long-horizon performance improves when the agent keeps durable written context in repo files instead of relying on short-term chat memory.

## File pattern

Use four files as operational control points:

- `Prompt.md`: objective, acceptance criteria, constraints, and scope boundaries
- `Plans.md`: milestone decomposition, risk register, decision log, and verification checklist
- `Implement.md`: execution contract (autonomy rules, validation cadence, blocked protocol)
- `Documentation.md`: continuously updated user/developer documentation

## Practical guidance

- Write plan artifacts before heavy implementation.
- Keep milestones small enough to verify in one pass.
- Record assumptions and decisions when ambiguity appears.
- Keep a standing verification checklist in `Plans.md` and update it continuously.
- Treat verification as evidence of progress, not as a substitute for delivering requested behavior.

## Suggested cadence

- At milestone start: confirm scope and verification commands.
- During implementation: update plan notes when decisions change architecture or scope.
- At milestone end: update status, verification result, and next milestone owner/action.

## Comparison note

This approach overlaps with objective-first loop systems (for example Ralph-style loops), but this skill focuses on planning and operating contract files first so long-running implementation remains readable, resumable, and auditable.

In v0.1, this skill adds a runnable objective-first loop (`scripts/run_long_horizon_loop.sh`) while preserving the four planner files as the control plane.
