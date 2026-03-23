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
[[ -x "$SKILL_DIR/scripts/init_repo.sh" ]] || fail "scripts/init_repo.sh is missing or not executable"
[[ -x "$SKILL_DIR/scripts/show_secrets.sh" ]] || fail "scripts/show_secrets.sh is missing or not executable"
[[ -x "$SKILL_DIR/scripts/install_skill.sh" ]] || fail "scripts/install_skill.sh is missing or not executable"

# Basic frontmatter checks without Python dependencies.
head -n 40 "$SKILL_DIR/SKILL.md" | grep -q '^---$' || fail "SKILL.md missing YAML frontmatter delimiter"
head -n 40 "$SKILL_DIR/SKILL.md" | grep -q '^name:' || fail "SKILL.md missing frontmatter name"
head -n 40 "$SKILL_DIR/SKILL.md" | grep -q '^description:' || fail "SKILL.md missing frontmatter description"

bash -n "$SKILL_DIR/scripts/init_repo.sh" || fail "init_repo.sh shell syntax invalid"
bash -n "$SKILL_DIR/scripts/show_secrets.sh" || fail "show_secrets.sh shell syntax invalid"
bash -n "$SKILL_DIR/scripts/install_skill.sh" || fail "install_skill.sh shell syntax invalid"

pass "Skill structure and shell scripts validated"
