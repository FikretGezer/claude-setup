# Installs everything from this repo into the CURRENT user's Claude Code config (~/.claude).
# Idempotent: safe to run many times. It never deletes anything it did not create.
#
#   powershell -ExecutionPolicy Bypass -File scripts\install.ps1
#   options:
#     -LibPath <dir>      where the visual-library repo lives / should be cloned
#                         (default: ~\Desktop\Claude Projects\visual-library)
#     -SkipClone          do not clone visual-library (only wire up skills + rules)
#     -CavemanFallback    also install the local fallback `caveman` skill
#                         (use ONLY when the official caveman plugin is not available)
param(
  [string]$LibPath = '',
  [switch]$SkipClone,
  [switch]$CavemanFallback
)
$ErrorActionPreference = 'Stop'

$repo    = (Resolve-Path (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) '..')).Path
$homeDir = if ($env:VL_HOME) { $env:VL_HOME } else { $HOME }       # VL_HOME is for testing only
$claude  = Join-Path $homeDir '.claude'
$utf8    = New-Object System.Text.UTF8Encoding($false)
if (-not $LibPath) { $LibPath = Join-Path $homeDir 'Desktop\Claude Projects\visual-library' }
$LibPath = [IO.Path]::GetFullPath($LibPath)

function Step($m) { Write-Host "==> $m" -ForegroundColor Cyan }

# ---- 1) visual-library repo -------------------------------------------------
Step "visual-library: $LibPath"
if (Test-Path (Join-Path $LibPath 'library.js')) {
  Write-Host "already there, leaving it alone"
} elseif ($SkipClone) {
  Write-Host "skipped (-SkipClone)"
} else {
  $parent = Split-Path -Parent $LibPath
  New-Item -ItemType Directory -Force -Path $parent | Out-Null
  $cloned = $false
  # Windows PowerShell 5.1 turns git's normal progress text (stderr) into a terminating error
  # when ErrorActionPreference is Stop, so relax it around native commands and trust the exit code.
  $ErrorActionPreference = 'Continue'
  if (Get-Command gh -ErrorAction SilentlyContinue) {
    & gh repo clone FikretGezer/visual-library $LibPath
    $cloned = ($LASTEXITCODE -eq 0)
  }
  if (-not $cloned) {
    if (Test-Path $LibPath) { Remove-Item -Recurse -Force $LibPath -ErrorAction SilentlyContinue }
    & git clone https://github.com/FikretGezer/visual-library.git $LibPath
    $cloned = ($LASTEXITCODE -eq 0)
  }
  $ErrorActionPreference = 'Stop'
  if (-not $cloned) {
    Write-Host ""
    Write-Host "CLONE FAILED. The repo is private: run 'gh auth login' (browser login as FikretGezer), then run this script again." -ForegroundColor Yellow
    exit 2
  }
}

# ---- 2) skills ---------------------------------------------------------------
$skills = @('visual', 'ship')
if ($CavemanFallback) { $skills += 'caveman' }
foreach ($name in $skills) {
  Step "skill: $name"
  $dst = Join-Path $claude "skills\$name"
  New-Item -ItemType Directory -Force -Path $dst | Out-Null
  $text = [IO.File]::ReadAllText((Join-Path $repo "skills\$name\SKILL.md"), $utf8).Replace('{{LIB}}', $LibPath)
  [IO.File]::WriteAllText((Join-Path $dst 'SKILL.md'), $text, $utf8)
}

# ---- 3) CLAUDE.md block (replaced in place between markers) -------------------
Step "CLAUDE.md rules"
$start = '<!-- claude-setup:start -->'
$end   = '<!-- claude-setup:end -->'
$old1  = '<!-- visual-library:start -->'; $old2 = '<!-- visual-library:end -->'   # block name used by an earlier version
$block = $start + "`n" + [IO.File]::ReadAllText((Join-Path $repo 'claude-md.template.md'), $utf8).Replace('{{LIB}}', $LibPath).TrimEnd() + "`n" + $end + "`n"
$file  = Join-Path $claude 'CLAUDE.md'
New-Item -ItemType Directory -Force -Path $claude | Out-Null
$cur   = if (Test-Path $file) { [IO.File]::ReadAllText($file, $utf8) } else { '' }
foreach ($pair in @(@($start, $end), @($old1, $old2))) {
  $pat = '(?s)' + [regex]::Escape($pair[0]) + '.*?' + [regex]::Escape($pair[1]) + "\r?\n?"
  $cur = [regex]::Replace($cur, $pat, '')
}
$cur = $cur.TrimEnd()
if ($cur.Length -gt 0) { $cur += "`n`n" }
[IO.File]::WriteAllText($file, $cur + $block, $utf8)
Write-Host "updated $file"

Write-Host ""
Write-Host "INSTALL OK. Library: $LibPath" -ForegroundColor Green
Write-Host "Next: install plugins (superpowers, caveman) as described in INSTRUCTIONS-FOR-CLAUDE.md, then run scripts\verify.ps1 and start a NEW Claude Code session."
