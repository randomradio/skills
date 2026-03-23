#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

fail() {
  echo "[FAIL] $1" >&2
  exit 1
}

pass() {
  echo "[OK] $1"
}

[[ -f "$SKILL_DIR/SKILL.md" ]] || fail "Missing SKILL.md"
[[ -f "$SKILL_DIR/agents/openai.yaml" ]] || fail "Missing agents/openai.yaml"
[[ -f "$SKILL_DIR/references/openai-long-horizon-notes.md" ]] || fail "Missing references/openai-long-horizon-notes.md"
[[ -x "$SKILL_DIR/scripts/init_long_horizon_workspace.sh" ]] || fail "scripts/init_long_horizon_workspace.sh missing or not executable"
[[ -x "$SKILL_DIR/scripts/validate_long_horizon_workspace.sh" ]] || fail "scripts/validate_long_horizon_workspace.sh missing or not executable"
[[ -x "$SKILL_DIR/scripts/install_skill.sh" ]] || fail "scripts/install_skill.sh missing or not executable"

head -n 20 "$SKILL_DIR/SKILL.md" | grep -q '^---$' || fail "SKILL.md missing YAML frontmatter delimiter"
head -n 20 "$SKILL_DIR/SKILL.md" | grep -q '^name:' || fail "SKILL.md missing frontmatter name"
head -n 20 "$SKILL_DIR/SKILL.md" | grep -q '^description:' || fail "SKILL.md missing frontmatter description"

bash -n "$SKILL_DIR/scripts/init_long_horizon_workspace.sh" || fail "init_long_horizon_workspace.sh has shell syntax errors"
bash -n "$SKILL_DIR/scripts/validate_long_horizon_workspace.sh" || fail "validate_long_horizon_workspace.sh has shell syntax errors"
bash -n "$SKILL_DIR/scripts/install_skill.sh" || fail "install_skill.sh has shell syntax errors"

pass "Skill structure and shell scripts validated"
