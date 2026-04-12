#!/usr/bin/env bash
set -euo pipefail

# Install randomradio plugin to Claude Code, Codex, or both.
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/randomradio/skills/master/install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/randomradio/skills/master/install.sh | bash -s -- --target codex
#   curl -fsSL https://raw.githubusercontent.com/randomradio/skills/master/install.sh | bash -s -- --target claude

REPO_URL="https://github.com/randomradio/skills.git"
REPO_BRANCH="master"
CACHE_DIR="$HOME/.cache/randomradio-skills/repo"
PLUGIN_DIR="plugins/randomradio"
TARGET="${1:-auto}"

# Strip -- prefix if present
[[ "$TARGET" == "--target" ]] && TARGET="${2:-auto}"

log()  { echo "[randomradio] $*"; }
warn() { echo "[randomradio] WARN: $*" >&2; }

has_claude() { command -v claude >/dev/null 2>&1; }
has_codex()  { command -v codex >/dev/null 2>&1 || [[ -d "$HOME/.codex/skills" ]]; }

# --- Clone/refresh ---

mkdir -p "$(dirname "$CACHE_DIR")"
if [[ ! -d "$CACHE_DIR/.git" ]]; then
  log "Cloning $REPO_URL..."
  git clone --depth 1 --branch "$REPO_BRANCH" "$REPO_URL" "$CACHE_DIR"
else
  log "Updating cache..."
  git -C "$CACHE_DIR" fetch origin "$REPO_BRANCH" --depth 1
  git -C "$CACHE_DIR" reset --hard "origin/$REPO_BRANCH"
fi

log "Commit: $(git -C "$CACHE_DIR" rev-parse --short HEAD)"

# --- Detect targets ---

targets=()
if [[ "$TARGET" == "auto" ]]; then
  has_claude && targets+=("claude")
  has_codex  && targets+=("codex")
  [[ ${#targets[@]} -eq 0 ]] && { warn "No supported platforms found (need claude or codex)"; exit 1; }
  log "Auto-detected: ${targets[*]}"
elif [[ "$TARGET" == "all" ]]; then
  targets=("claude" "codex")
else
  targets=("$TARGET")
fi

# --- Install ---

for t in "${targets[@]}"; do
  case "$t" in

    claude)
      log "Installing to Claude Code..."
      if ! has_claude; then
        warn "claude CLI not found, skipping"
        continue
      fi
      # Register marketplace if needed
      if ! claude plugin marketplace list 2>/dev/null | grep -q "randomradio-skills"; then
        claude plugin marketplace add "$CACHE_DIR" 2>/dev/null || true
      fi
      claude plugin marketplace update randomradio-skills 2>/dev/null || true
      if claude plugin list 2>/dev/null | grep -q "randomradio@"; then
        claude plugin update randomradio 2>/dev/null || warn "Update failed (may need restart)"
      else
        claude plugin install randomradio 2>/dev/null || warn "Install failed"
      fi
      log "Claude Code: done"
      ;;

    codex)
      log "Installing to Codex..."
      codex_dir="${CODEX_HOME:-$HOME/.codex}/skills"
      mkdir -p "$codex_dir"
      plugin_root="$CACHE_DIR/$PLUGIN_DIR"
      count=0

      # Skills
      for skill_dir in "$plugin_root"/skills/*/; do
        [[ -d "$skill_dir" ]] || continue
        name="$(basename "$skill_dir")"
        dest="$codex_dir/$name"
        rm -rf "$dest"
        mkdir -p "$dest"
        cp -R "$skill_dir"* "$dest/" 2>/dev/null || cp -R "$skill_dir". "$dest/"
        count=$((count + 1))
      done

      # Agents (flatten to skills)
      for agent_file in "$plugin_root"/agents/*/*.md; do
        [[ -f "$agent_file" ]] || continue
        name="$(basename "$agent_file" .md)"
        dest="$codex_dir/$name"
        rm -rf "$dest"
        mkdir -p "$dest"
        cp "$agent_file" "$dest/SKILL.md"
        count=$((count + 1))
      done

      log "Codex: installed $count items to $codex_dir"
      ;;

    *)
      warn "Unknown target: $t"
      ;;
  esac
done

log "Done! Restart your coding agent to pick up the new skills."
