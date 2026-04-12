# Plugin Conventions

## Skill Structure

Every skill follows this layout:

```
skills/<skill-name>/
├── SKILL.md              # Entry point with YAML frontmatter
├── references/           # On-demand loaded docs (save tokens)
└── scripts/              # Shell scripts (optional)
```

## SKILL.md Format

```yaml
---
name: rr:<skill-name>
description: When to use this skill
argument-hint: "[optional argument description]"
---
```

## Namespace

All skills use `rr:` prefix. Invoked as `/rr:<skill-name>` or `rr:<skill-name>`.

## Agent Format

```yaml
---
name: <agent-name>
description: When this agent is selected
model: inherit
tools: Read, Grep, Glob, Bash
---
```

## References

Load references only when needed during execution, not at skill load time.
Use: "Read `references/<file>.md` before proceeding to Phase N."

## Arguments

Use `#$ARGUMENTS` as the template variable for skill arguments.
