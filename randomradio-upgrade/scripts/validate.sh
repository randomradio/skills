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
[[ -x "$SKILL_DIR/scripts/install_skill.sh" ]] || fail "scripts/install_skill.sh missing or not executable"
[[ -x "$SKILL_DIR/scripts/upgrade_skills.sh" ]] || fail "scripts/upgrade_skills.sh missing or not executable"
[[ -x "$SKILL_DIR/scripts/uninstall_personal_skills.sh" ]] || fail "scripts/uninstall_personal_skills.sh missing or not executable"

head -n 20 "$SKILL_DIR/SKILL.md" | grep -q '^---$' || fail "SKILL.md missing YAML frontmatter delimiter"
head -n 20 "$SKILL_DIR/SKILL.md" | grep -q '^name:' || fail "SKILL.md missing frontmatter name"
head -n 20 "$SKILL_DIR/SKILL.md" | grep -q '^description:' || fail "SKILL.md missing frontmatter description"

bash -n "$SKILL_DIR/scripts/install_skill.sh" || fail "install_skill.sh has shell syntax errors"
bash -n "$SKILL_DIR/scripts/upgrade_skills.sh" || fail "upgrade_skills.sh has shell syntax errors"
bash -n "$SKILL_DIR/scripts/uninstall_personal_skills.sh" || fail "uninstall_personal_skills.sh has shell syntax errors"

VALIDATION_ROOT="$(mktemp -d)"
trap 'rm -rf "$VALIDATION_ROOT"' EXIT
VALIDATION_SKILLS="$VALIDATION_ROOT/codex/skills"
mkdir -p "$VALIDATION_SKILLS/.system" "$VALIDATION_SKILLS/example" "$VALIDATION_SKILLS/notes"
touch "$VALIDATION_SKILLS/.system/SKILL.md" "$VALIDATION_SKILLS/example/SKILL.md" "$VALIDATION_SKILLS/notes/readme.txt"

"$SKILL_DIR/scripts/uninstall_personal_skills.sh" --codex-dir "$VALIDATION_SKILLS" --dry-run >/dev/null
[[ -d "$VALIDATION_SKILLS/example" ]] || fail "Dry run removed a personal skill"

"$SKILL_DIR/scripts/uninstall_personal_skills.sh" --codex-dir "$VALIDATION_SKILLS" --yes >/dev/null
[[ ! -e "$VALIDATION_SKILLS/example" ]] || fail "Personal skill was not removed"
[[ -f "$VALIDATION_SKILLS/.system/SKILL.md" ]] || fail ".system was removed"
[[ -f "$VALIDATION_SKILLS/notes/readme.txt" ]] || fail "Non-skill entry was removed"

rm -rf "$VALIDATION_ROOT"
trap - EXIT

pass "Skill structure and shell scripts validated"
