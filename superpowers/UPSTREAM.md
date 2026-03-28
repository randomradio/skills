# Superpowers Upstream

This directory vendors the upstream skill tree from [`obra/superpowers`](https://github.com/obra/superpowers).

## Snapshot

- Source repo: `https://github.com/obra/superpowers`
- Imported commit: `eafe962b18f6c5dc70fb7c8cc7e83e61f4cdde06`
- Commit date: `2026-03-25T11:08:09-07:00`
- Imported subtree: upstream `skills/`
- License: MIT, preserved in [`LICENSE`](LICENSE)

## Why This Layout

Upstream's Codex install docs expose the skill pack by wiring `~/.agents/skills/superpowers` to the upstream `skills/` directory. This repo mirrors that layout by keeping the vendored skill directories directly under `superpowers/`.

Import the full subtree, not just `using-superpowers`. Several skills depend on sibling prompts, references, scripts, and supporting markdown files.

## Refreshing From Upstream

1. Clone `obra/superpowers` into a temporary directory.
2. Replace this directory's contents with the upstream `skills/` subtree.
3. Copy the upstream `LICENSE` into [`LICENSE`](LICENSE).
4. Update the commit and date in this file.

Example:

```bash
tmpdir=$(mktemp -d)
git clone --depth 1 https://github.com/obra/superpowers.git "$tmpdir"
cp -R "$tmpdir/skills/." superpowers/
cp "$tmpdir/LICENSE" superpowers/LICENSE
```
