#!/usr/bin/env bash
set -euo pipefail

CODEX_DIR=""
DRY_RUN=0
YES=0

usage() {
  cat <<'USAGE'
Usage:
  uninstall_personal_skills.sh [options]

Options:
  --codex-dir <path>  Codex skills directory (default: $CODEX_HOME/skills or ~/.codex/skills)
  --dry-run           List personal skills without removing them
  --yes               Remove skills without an interactive confirmation
  -h, --help          Show this help

The script removes each top-level skill that contains a SKILL.md file. It keeps
the built-in .system directory and entries that are not skills.
USAGE
}

fail() {
  echo "[ERROR] $*" >&2
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --codex-dir)
      [[ $# -ge 2 ]] || fail "--codex-dir needs a path"
      CODEX_DIR="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --yes)
      YES=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      fail "Unknown argument: $1"
      ;;
  esac
done

if [[ -z "$CODEX_DIR" ]]; then
  CODEX_DIR="${CODEX_HOME:-$HOME/.codex}/skills"
fi

if [[ ! -d "$CODEX_DIR" ]]; then
  echo "No Codex skills directory found at: $CODEX_DIR"
  exit 0
fi

CODEX_DIR="$(cd "$CODEX_DIR" && pwd -P)"
[[ "$(basename "$CODEX_DIR")" == "skills" ]] || \
  fail "Refusing to use a directory that is not named 'skills': $CODEX_DIR"

skills=()
shopt -s dotglob nullglob
for candidate in "$CODEX_DIR"/*; do
  [[ "$(basename "$candidate")" == ".system" ]] && continue
  [[ -f "$candidate/SKILL.md" ]] || continue
  skills+=("$candidate")
done
shopt -u dotglob nullglob

if [[ ${#skills[@]} -eq 0 ]]; then
  echo "No personal skills found in: $CODEX_DIR"
  exit 0
fi

echo "Personal skills in $CODEX_DIR:"
for skill in "${skills[@]}"; do
  echo "  - $(basename "$skill")"
done

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "Dry run: no skills were removed."
  exit 0
fi

if [[ "$YES" -ne 1 ]]; then
  if [[ ! -t 0 ]]; then
    fail "Confirmation is required. Run again with --yes for non-interactive use."
  fi

  read -r -p "Remove all ${#skills[@]} personal skills? [y/N]: " reply
  case "$reply" in
    y|Y|yes|YES) ;;
    *)
      echo "No skills were removed."
      exit 0
      ;;
  esac
fi

for skill in "${skills[@]}"; do
  rm -rf -- "$skill"
done

echo "Removed ${#skills[@]} personal skills. The .system directory was kept."
