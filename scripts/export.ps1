# Run on the MAIN computer after you change a skill or rule locally.
# Copies the live skills from ~/.claude back into this repo (turning the library path back into {{LIB}}).
#   powershell -ExecutionPolicy Bypass -File scripts\export.ps1 [-LibPath <dir>]
# Then: git add -A; git commit; git push   (the `ship` skill does this for you).
param([string]$LibPath = '')
$ErrorActionPreference = 'Stop'
$repo    = (Resolve-Path (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) '..')).Path
$homeDir = if ($env:VL_HOME) { $env:VL_HOME } else { $HOME }
$claude  = Join-Path $homeDir '.claude'
$utf8    = New-Object System.Text.UTF8Encoding($false)
if (-not $LibPath) { $LibPath = Join-Path $homeDir 'Desktop\Claude Projects\visual-library' }
$LibPath = [IO.Path]::GetFullPath($LibPath)

foreach ($name in 'visual', 'ship') {
  $src = Join-Path $claude "skills\$name\SKILL.md"
  if (-not (Test-Path $src)) { Write-Host "missing $src - skipped"; continue }
  $text = [IO.File]::ReadAllText($src, $utf8).Replace($LibPath, '{{LIB}}')
  [IO.File]::WriteAllText((Join-Path $repo "skills\$name\SKILL.md"), $text, $utf8)
  Write-Host "exported skill: $name"
}
Write-Host "Rules template (claude-md.template.md) is edited by hand in this repo; export does not touch it."
