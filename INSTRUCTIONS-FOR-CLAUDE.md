# Instructions for Claude: set up this computer

You are Claude Code (or the Claude desktop Code tab) on a **second computer** of the user (GitHub: `FikretGezer`).
The user gave you this repository so that you do the whole setup yourself. **Do every step below without asking the user to touch anything**, except the two things only they can do (marked **USER ONLY**).

Reply to the user in **Turkish**, in a short, direct style (they use "caveman" style). Report at the end.

## What you are building

The user's main PC has a set of Claude Code customisations. This repo reproduces them here:

| Piece | What it is | Where it ends up |
|---|---|---|
| `visual` skill | `/visual` command: lists, searches, opens, adds entries of the user's library of animated visuals / wallpapers | `~/.claude/skills/visual/SKILL.md` |
| `ship` skill | `/ship`: commits, bumps semver, writes CHANGELOG, pushes, creates a GitHub release | `~/.claude/skills/ship/SKILL.md` |
| rules block | Global rules: caveman style always on, use skills proactively, verify the real usage path before saying done, check the visual library first | marked block inside `~/.claude/CLAUDE.md` |
| visual-library | The user's private repo of visuals (`FikretGezer/visual-library`) | `~\Desktop\Claude Projects\visual-library` |
| plugins | `superpowers` (debugging, verification, brainstorming, planning skills) and `caveman` (terse reply style) | Claude plugin directory |

Skills live per machine in `~/.claude`, so they do not sync by themselves. That is why this repo exists.

## Ground rules for you

- Windows + PowerShell. Paths contain a space (`Claude Projects`), so always quote paths.
- **Never type, ask for, or store passwords, tokens or API keys.** Logging in to GitHub is **USER ONLY** (step 2).
- Do not touch `~/.claude` files other than: `skills/visual`, `skills/ship`, `skills/caveman` (only with the fallback switch), and the block between `<!-- claude-setup:start -->` and `<!-- claude-setup:end -->` in `CLAUDE.md`. The install script already follows this. Do not delete anything the user already has.
- If the user already has a `~/.claude/CLAUDE.md`, keep its content. The script only adds or replaces its own marked block.
- Do not use `--force`, do not rewrite git history.

## Steps

### 1. Check the machine
Run and read the output:
```powershell
git --version
gh --version
$PSVersionTable.PSVersion
```
- `git` missing: `winget install --id Git.Git -e` then reopen the shell.
- `gh` missing: `winget install --id GitHub.cli -e` then reopen the shell.
- `winget` missing: tell the user (Turkish) which of the two to install by hand and stop.

### 2. GitHub login (**USER ONLY**)
```powershell
gh auth status
```
- If it says logged in as `FikretGezer`: continue.
- If not logged in: tell the user, in one line, to run `gh auth login` in the terminal (GitHub.com, HTTPS, login with browser) and to say "tamam" afterwards. **Wait.** Do not try to log in for them. Both this repo and `visual-library` are private; nothing works without it.
- Logged in as a different account: tell the user; the repos belong to `FikretGezer`.

### 3. Run the installer
From the root of this repo (the folder that contains this file):
```powershell
powershell -ExecutionPolicy Bypass -File scripts\install.ps1
```
It will:
1. clone `FikretGezer/visual-library` to `~\Desktop\Claude Projects\visual-library` (skipped if it already exists),
2. install the `visual` and `ship` skills with the library path of this PC filled in,
3. add/replace the rules block in `~/.claude/CLAUDE.md`.

Options: `-LibPath <dir>` to use another folder for the library, `-SkipClone`, `-CavemanFallback` (step 4).
Exit code 2 = clone failed because of login: go back to step 2.

### 4. Plugins
Try the CLI first (these subcommands exist in current Claude Code; if the `claude` command is not on PATH, skip to the fallback):
```powershell
claude plugin marketplace add obra/superpowers-marketplace
claude plugin install superpowers@superpowers-marketplace
```
If the CLI refuses or is not available, tell the user to type these in a Claude Code session (slash commands cannot be run by you):
```
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace
```

**caveman**: on the main PC it comes from the Claude desktop app's account plugin list, not from a public marketplace I can name. Check whether it exists here: look at the skills listed in your own session for `caveman:caveman`, or run `scripts\verify.ps1` (step 5).
- Present: done.
- Missing: install the local fallback (same behaviour, own wording):
  ```powershell
  powershell -ExecutionPolicy Bypass -File scripts\install.ps1 -CavemanFallback
  ```
  and tell the user they may later enable the official plugin in the desktop app.

### 5. Verify
```powershell
powershell -ExecutionPolicy Bypass -File scripts\verify.ps1
```
Expected: every line `PASS`, last line `ALL CHECKS PASSED`. Fix each `FAIL` using its hint, then run again. Do not report success while any line says FAIL.

Also prove the library really works in the way the user will use it: open `~\Desktop\Claude Projects\visual-library\gallery.html` (double-click equivalent, `Start-Process`) and check that it shows at least the entries listed in `library.js`. Do not test only through a local web server; the user opens the files directly.

### 6. Tell the user to start a new session
Skills and CLAUDE.md are read when a session starts. The current session may not see `/visual`. Say: yeni oturum aç, `/visual` yaz.

### 7. Report (Turkish, short)
Say: what was installed, what passed, what the user still has to do (login, plugin command, new session) if anything. List any FAIL honestly.

## Troubleshooting

| Symptom | Cause / fix |
|---|---|
| `running scripts is disabled` | Always call with `powershell -ExecutionPolicy Bypass -File ...` as shown. |
| Clone: `Repository not found` | Not logged in, or wrong account. `gh auth status`, redo step 2. |
| `/visual` not found in the new session | Check `~/.claude/skills/visual/SKILL.md` exists; start a fully new session (not resume). |
| Skill file still contains `{{LIB}}` | Template was copied by hand. Run `install.ps1` again. |
| `CLAUDE.md` has the rules twice | The script replaces its own block; a hand-copied duplicate is outside the markers. Remove the duplicate by hand, keep the marked block. |
| `claude plugin ...` not recognised | Old CLI or not on PATH. Use the slash commands, ask the user. |
| Gallery cards show empty previews | Open the visual itself (`Aç` button) or serve the folder: `python -m http.server 8765` in the library folder. The visuals themselves work from `file://`. |
| Memory plugin (claude-mem) shows an error about subscription access | Unrelated to this setup. Ignore. |

## Updating later

- **Main PC, after changing a skill:** `powershell -ExecutionPolicy Bypass -File scripts\export.ps1`, then commit and push this repo (`ship` skill).
- **This PC:** `git pull` in this repo, then run `scripts\install.ps1` again, then `scripts\verify.ps1`.
- New visuals are in the **visual-library** repo; `git pull` there.

## Reference: main PC at the time this was written (2026-11-23)

- Windows 11, PowerShell. Library at `C:\Users\USER\Desktop\Claude Projects\visual-library`.
- User-level skills added by the user: `visual`, `ship`. Plugins in use: `superpowers@superpowers-marketplace`, `claude-mem@thedotmack` (optional, not required for this setup), `caveman` from the desktop app.
- The user wants: caveman replies always, skills chosen automatically, "done" only after the real usage path was tested, push work to GitHub with versioned notes via `ship`.
