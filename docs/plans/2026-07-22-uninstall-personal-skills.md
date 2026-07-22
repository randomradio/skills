# Uninstall Personal Skills Plan

**Goal:** Add a safe script that removes all Codex personal skills and keeps built-in system skills.

## Success Criteria

- [x] List personal skills before removal.
- [x] Keep the `.system` directory and non-skill entries.
- [x] Require confirmation, or accept `--yes` for automation.
- [x] Support `--dry-run` and `--codex-dir`.
- [x] Validate the script with an isolated temporary skills directory.

## Work

1. Add the uninstall script.
2. Add the command to the skill instructions and interface metadata.
3. Extend validation and run an isolated behavior test.

## Result

The isolated tests verified dry-run output, non-interactive confirmation,
automated removal, `.system` preservation, unrelated-entry preservation, and
removal of the installed manager skill while its script runs.
