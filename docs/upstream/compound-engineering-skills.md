# Compound Engineering Skill Lineage

RandomRadio keeps a set of skills that are derived from, inspired by, or
independent of Compound Engineering skills. This file defines the maintenance
model; `plugins/randomradio/skills/upstream.json` is the machine-readable source
for the mapping and the local compatibility contracts that protect RandomRadio
changes during upstream sync.

## Policy

RandomRadio skills are the source of record for installation, publication, and
the public market. Compound Engineering skills are comparison sources for
selective updates.

Use these modes:

| Mode | Meaning | Update behavior |
|---|---|---|
| `mirror` | Local skill should match upstream except identity metadata | Copy upstream changes after verifying local namespace metadata |
| `fork` | Local skill is derived from upstream and intentionally diverges | Compare upstream before updates; adopt improvements unless they break local contracts |
| `inspired` | Upstream influenced the design, but the skill is not synced | Use upstream only as context |
| `original` | Repo-owned skill with no tracked upstream | Update directly in this repo |

## Local Compatibility Contracts

These contracts survive upstream adoption:

- Public skill names stay under `rr:<skill-id>`.
- RandomRadio install, registry, market, and release behavior stay repo-owned.
- Additive updates use non-breaking semantic version bumps.
- Local workflow simplifications can stay when they make the skill better for
  this collection.

Each CE-derived skill must also define `localCompatibility` in
`plugins/randomradio/skills/upstream.json`:

| Field | Purpose |
|---|---|
| `syncStrategy` | Short rule for how to combine upstream improvements with the local fork |
| `preserve` | Human-readable local changes that must survive sync |
| `requiredMarkers` | Exact strings that must remain in the local `SKILL.md` |

`node scripts/compare-upstream-skills.mjs --check --allow-missing-upstream`
fails if a CE fork is missing this contract, if `name: rr:<skill-id>` is lost,
or if any required marker disappears. This makes sync compatibility a CI gate,
not a memory exercise.

## Compare Workflow

Run:

```bash
node scripts/compare-upstream-skills.mjs
node scripts/compare-upstream-skills.mjs --write-report docs/upstream/compound-engineering-skill-report.md
```

By default the script looks for upstream skills in `~/.codex/skills`. Override
that with:

```bash
COMPOUND_ENGINEERING_SKILLS_ROOT=/path/to/skills node scripts/compare-upstream-skills.mjs
```

CI runs only the manifest validation path:

```bash
node scripts/compare-upstream-skills.mjs --check --allow-missing-upstream
```

That keeps CI independent from any private local installation while still
requiring every published skill to declare its lineage and every CE fork to
declare the local contract that sync must preserve.
