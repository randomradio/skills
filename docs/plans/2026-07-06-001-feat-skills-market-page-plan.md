---
title: "feat: Build skills market page"
type: feat
status: completed
date: 2026-07-06
---

# feat: Build skills market page

## Summary

Build a static `skills.icyzhao.com` market page for the current RandomRadio skills collection, backed by a generated registry file so future install/update work can reuse the same catalog data.

---

## Problem Frame

The repository has install and upgrade scripts, but no public catalog surface that lets a user scan the available skills, understand what each one does, and copy the current install/update command. The page should be useful before the full long-term single-skill installer exists.

---

## Requirements

- R1. Generate a repo-owned skill registry from `plugins/randomradio/skills/*/SKILL.md`.
- R2. Build a static market page that loads the registry and renders search, category filters, stats, and skill cards.
- R3. Show truthful collection-level install/update commands instead of inventing unsupported per-skill install commands.
- R4. Keep the page deployable as static assets for `skills.icyzhao.com`.
- R5. Verify the page locally in a browser-sized viewport.

---

## Key Technical Decisions

- **Static first:** Use HTML, CSS, and vanilla JavaScript so the page can deploy directly to Cloudflare Pages or any static host without adding a package manager to this repo.
- **Generated registry:** Keep `site/registry.json` as the page data source and add a small build script that regenerates it from skill frontmatter.
- **Collection install semantics:** Present the existing install/update scripts as collection-level actions while single-skill installation remains future work.

---

## Implementation Units

### U1. Registry Generator

- **Goal:** Create a generated catalog from current skill frontmatter.
- **Files:** `site/scripts/build-registry.mjs`, `site/registry.json`
- **Approach:** Parse the supported YAML frontmatter subset, derive category/feature metadata, count agents, and write stable JSON.
- **Test scenarios:** Regeneration includes 19 skills; descriptions from block-style frontmatter are preserved; plugin version is used where a skill has no version.
- **Verification:** Running the script rewrites valid JSON and reports the skill count.

### U2. Static Market Page

- **Goal:** Render a polished, searchable market page from the registry.
- **Files:** `site/index.html`, `site/styles.css`, `site/app.js`, `site/README.md`
- **Approach:** Build a compact developer-tool marketplace with first-class install/update commands, filters, search, sort, copy buttons, and responsive cards.
- **Test scenarios:** Search narrows by name/description/category; category tabs filter correctly; copy buttons update their labels; the empty state appears when no cards match.
- **Verification:** Serve `site/` locally and inspect the page at desktop and mobile widths.
