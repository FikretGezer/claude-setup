# Checks that the setup is complete. Prints PASS/FAIL per item and exits 1 if anything failed.
#   powershell -ExecutionPolicy Bypass -File scripts\verify.ps1 [-LibPath <dir>]
param([string]$LibPath = '')
$homeDir = if ($env:VL_HOME) { $env:VL_HOME } else { $HOME }
$claude  = Join-Path $homeDir '.claude'
$utf8    = New-Object System.Text.UTF8Encoding($false)
if (-not $LibPath) { $LibPath = Join-Path $homeDir 'Desktop\Claude Projects\visual-library' }
$fail = 0
function Check($ok, $label, $hint) {
  if ($ok) { Write-Host "PASS  $label" -ForegroundColor Green }
  else     { Write-Host "FAIL  $label  -> $hint" -ForegroundColor Red; $script:fail++ }
}

Check ([bool](Get-Command git -ErrorAction SilentlyContinue)) 'git installed' 'install Git for Windows'
$gh = [bool](Get-Command gh -ErrorAction SilentlyContinue)
Check $gh 'gh (GitHub CLI) installed' 'winget install --id GitHub.cli'
if ($gh) { & gh auth status *> $null; Check ($LASTEXITCODE -eq 0) 'gh logged in' "run 'gh auth login' (user must do this)" }

Check (Test-Path (Join-Path $LibPath 'library.js'))   "visual-library present ($LibPath)" 'run install.ps1 (needs gh login for the private repo)'
Check (Test-Path (Join-Path $LibPath 'gallery.html')) 'gallery.html present' 'git -C <lib> pull'

foreach ($n in 'visual', 'ship') {
  $p = Join-Path $claude "skills\$n\SKILL.md"
  $okFile = Test-Path $p
  Check $okFile "skill '$n' installed" 'run install.ps1'
  if ($okFile) {
    $t = [IO.File]::ReadAllText($p, $utf8)
    Check (-not $t.Contains('{{LIB}}')) "skill '$n' has no unreplaced placeholder" 'run install.ps1 again'
  }
}

$md = Join-Path $claude 'CLAUDE.md'
$mdOk = (Test-Path $md) -and ([IO.File]::ReadAllText($md, $utf8).Contains('<!-- claude-setup:start -->'))
Check $mdOk 'CLAUDE.md rules block present' 'run install.ps1'

$plugins = Join-Path $claude 'plugins\installed_plugins.json'
$sp = (Test-Path $plugins) -and ([IO.File]::ReadAllText($plugins, $utf8) -match 'superpowers')
Check $sp 'superpowers plugin installed' "claude plugin marketplace add obra/superpowers-marketplace ; claude plugin install superpowers@superpowers-marketplace"
$cvPlugin = (Test-Path $plugins) -and ([IO.File]::ReadAllText($plugins, $utf8) -match 'caveman')
$cvLocal  = Test-Path (Join-Path $claude 'skills\caveman\SKILL.md')
Check ($cvPlugin -or $cvLocal) 'caveman available (plugin or local fallback)' 'ask the user to enable the caveman plugin in the Claude desktop app, or run install.ps1 -CavemanFallback'

Write-Host ""
if ($fail -eq 0) { Write-Host "ALL CHECKS PASSED. Start a new Claude Code session." -ForegroundColor Green; exit 0 }
Write-Host "$fail check(s) failed." -ForegroundColor Red; exit 1
