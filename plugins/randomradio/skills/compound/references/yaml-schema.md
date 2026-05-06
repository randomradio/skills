# YAML Frontmatter Schema

`schema.yaml` is the canonical contract for `docs/solutions/` frontmatter written by `rr:compound`.

## Tracks

The `problem_type` determines the track.

| Track | problem_types |
|-------|---------------|
| **Bug** | `build_error`, `test_failure`, `runtime_error`, `performance_issue`, `database_issue`, `security_issue`, `ui_bug`, `integration_issue`, `logic_error` |
| **Knowledge** | `best_practice`, `documentation_gap`, `workflow_issue`, `developer_experience`, `architecture_pattern`, `design_pattern`, `tooling_decision`, `convention` |

## Category Mapping

- `build_error` -> `docs/solutions/build-errors/`
- `test_failure` -> `docs/solutions/test-failures/`
- `runtime_error` -> `docs/solutions/runtime-errors/`
- `performance_issue` -> `docs/solutions/performance-issues/`
- `database_issue` -> `docs/solutions/database-issues/`
- `security_issue` -> `docs/solutions/security-issues/`
- `ui_bug` -> `docs/solutions/ui-bugs/`
- `integration_issue` -> `docs/solutions/integration-issues/`
- `logic_error` -> `docs/solutions/logic-errors/`
- `developer_experience` -> `docs/solutions/developer-experience/`
- `workflow_issue` -> `docs/solutions/workflow-issues/`
- `best_practice` -> `docs/solutions/best-practices/`
- `documentation_gap` -> `docs/solutions/documentation-gaps/`
- `architecture_pattern` -> `docs/solutions/architecture-patterns/`
- `design_pattern` -> `docs/solutions/design-patterns/`
- `tooling_decision` -> `docs/solutions/tooling-decisions/`
- `convention` -> `docs/solutions/conventions/`

## YAML Safety Rules

Strict YAML parsers reject array items that start with a reserved indicator character as unquoted scalars. When writing array-of-string fields such as `symptoms`, `applies_when`, `tags`, or `related_components`, wrap a value in double quotes if it starts with any of:

```
`, [, *, &, !, |, >, %, @, ?
```

Also quote any array value containing `: `.

Example:

```yaml
symptoms:
  - "`npm test` exits before teardown runs"
```
