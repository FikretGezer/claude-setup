# Changelog

## v0.1.0 - 2026-11-23
First release: everything needed to rebuild the user's Claude Code setup on another computer.

### Added
- `INSTRUCTIONS-FOR-CLAUDE.md`: step-by-step instructions the second computer's Claude follows on its own. The user only logs in to GitHub once.
- `scripts/install.ps1`: clones the visual library, installs the `visual` and `ship` skills and the global rules. Safe to run again; it replaces only its own block in `CLAUDE.md`.
- `scripts/verify.ps1`: PASS/FAIL check of the whole setup.
- `scripts/export.ps1`: copies updated skills from the main PC back into this repo.
- Skills `visual`, `ship`, and a fallback `caveman` for when the official plugin is missing.
- Global rules template: caveman always on, choose skills automatically, test the real usage path before saying done, check the visual library first.

### Why
- Skills live per computer, so they need a repo to travel. One repo for all skill-related things keeps the visual library repo for visuals only.
