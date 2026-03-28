#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR=""
REPO_URL="https://github.com/randomradio/skills.git"
REPO_BRANCH="master"
CACHE_DIR="$HOME/.cache/randomradio-skills/repo"
SKILLS_CSV=""
DRY_RUN=0

usage() {
  cat <<USAGE
Usage:
  upgrade_skills.sh [--target-dir <path>] [--repo-url <url>] [--branch <name>] [--cache-dir <path>] [--skills <csv>] [--dry-run]

Behavior:
- With no --skills, auto-discovers every top-level skill in the repo that has scripts/install_skill.sh
- With --skills, upgrades only the named subset
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target-dir)
      TARGET_DIR="$2"
      shift 2
      ;;
    --repo-url)
      REPO_URL="$2"
      shift 2
      ;;
    --branch)
      REPO_BRANCH="$2"
      shift 2
      ;;
    --cache-dir)
      CACHE_DIR="$2"
      shift 2
      ;;
    --skills)
      SKILLS_CSV="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$TARGET_DIR" ]]; then
  candidates=()
  if [[ -n "${CODEX_HOME:-}" ]]; then
    candidates+=("${CODEX_HOME}/skills")
  fi
  candidates+=("$HOME/.codex/skills" "$HOME/.claude/skills")

  for c in "${candidates[@]}"; do
    if [[ -d "$c" ]]; then
      TARGET_DIR="$c"
      break
    fi
  done

  if [[ -z "$TARGET_DIR" ]]; then
    TARGET_DIR="$HOME/.codex/skills"
  fi
fi

TARGET_DIR="$(mkdir -p "$TARGET_DIR" && cd "$TARGET_DIR" && pwd)"
mkdir -p "$(dirname "$CACHE_DIR")"

if [[ ! -d "$CACHE_DIR/.git" ]]; then
  if [[ "$DRY_RUN" -eq 0 ]]; then
    echo "[INFO] Cloning $REPO_URL -> $CACHE_DIR"
    git clone --depth 1 --branch "$REPO_BRANCH" "$REPO_URL" "$CACHE_DIR"
  else
    echo "[DRY] Would clone $REPO_URL -> $CACHE_DIR"
  fi
else
  if [[ "$DRY_RUN" -eq 0 ]]; then
    echo "[INFO] Refreshing cache at $CACHE_DIR"
    git -C "$CACHE_DIR" fetch origin "$REPO_BRANCH" --depth 1
    git -C "$CACHE_DIR" checkout "$REPO_BRANCH"
    git -C "$CACHE_DIR" reset --hard "origin/$REPO_BRANCH"
  else
    echo "[DRY] Would refresh cache at $CACHE_DIR"
  fi
fi

repo_commit="(dry-run)"
if [[ "$DRY_RUN" -eq 0 ]]; then
  repo_commit="$(git -C "$CACHE_DIR" rev-parse HEAD)"
fi

DISCOVERY_ROOT="$CACHE_DIR"
if [[ "$DRY_RUN" -eq 1 && ! -d "$CACHE_DIR" ]]; then
  if [[ -d "$REPO_URL" ]]; then
    DISCOVERY_ROOT="$(cd "$REPO_URL" && pwd)"
    echo "[DRY] Using local repo for discovery: $DISCOVERY_ROOT"
  elif [[ -z "$SKILLS_CSV" ]]; then
    echo "[ERROR] Dry run without an existing cache requires either a local repo path via --repo-url or an explicit --skills list" >&2
    exit 1
  fi
fi

discover_installable_skills() {
  local repo_root="$1"
  find "$repo_root" -mindepth 3 -maxdepth 3 -type f -path "$repo_root/*/scripts/install_skill.sh" \
    | sed -E "s#^$repo_root/([^/]+)/scripts/install_skill\\.sh#\\1#" \
    | sort -u
}

skill_list=()
if [[ -n "$SKILLS_CSV" ]]; then
  IFS=',' read -r -a skill_list <<< "$SKILLS_CSV"
else
  while IFS= read -r skill; do
    [[ -n "$skill" ]] || continue
    skill_list+=("$skill")
  done < <(discover_installable_skills "$DISCOVERY_ROOT")
fi

if [[ "${#skill_list[@]}" -eq 0 ]]; then
  echo "[ERROR] No installable skills found to upgrade" >&2
  exit 1
fi

echo "[INFO] Target skills dir: $TARGET_DIR"
echo "[INFO] Repo: $REPO_URL"
echo "[INFO] Branch: $REPO_BRANCH"
echo "[INFO] Commit: $repo_commit"
if [[ -n "$SKILLS_CSV" ]]; then
  echo "[INFO] Mode: explicit subset"
else
  echo "[INFO] Mode: auto-discover installable skills"
fi
echo "[INFO] Skills: ${skill_list[*]}"

for skill in "${skill_list[@]}"; do
  skill="$(echo "$skill" | xargs)"
  [[ -n "$skill" ]] || continue

  installer="$CACHE_DIR/$skill/scripts/install_skill.sh"
  if [[ ! -f "$installer" ]]; then
    if [[ "$DRY_RUN" -eq 1 ]]; then
      echo "[DRY] Would upgrade $skill (installer path unresolved in dry-run: $installer)"
      continue
    fi
    echo "[WARN] Skipping $skill (installer not found: $installer)"
    continue
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[DRY] Would upgrade $skill"
    continue
  fi

  echo "[INFO] Upgrading $skill"
  bash "$installer" --target-dir "$TARGET_DIR" --force --non-interactive >/dev/null

done

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "[OK] Dry run complete"
else
  echo "[OK] Upgrade complete"
fi
