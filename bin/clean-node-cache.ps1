#Requires -Version 5.1
param([ValidateSet('all','npm','yarn','pnpm','bun')][string]$Managers='all')
$Root = Split-Path -Parent $PSCommandPath; . "$Root\lib\common.ps1"
$targets = switch($Managers){
  'all'   { @('npm','yarn','pnpm','bun') }
  default { @($Managers) }
}
$any = $false
foreach($n in $targets){
  $exe = Get-Command $n -ErrorAction SilentlyContinue
  if (-not $exe){ continue }
  $any = $true
  switch($n){
    'npm'  { & $exe.Source cache clean --force | Out-Null }
    'yarn' { & $exe.Source cache clean | Out-Null }
    'pnpm' { & $exe.Source store prune | Out-Null }
    'bun'  { & $exe.Source pm cache rm | Out-Null }
  }
  Ok "Cleared $n cache"
}
if (-not $any){ Info "no managers on PATH"; exit 2 }
