#Requires -Version 5.1
param(
  [Parameter(Mandatory)][string]$RootDir,
  [string]$Branch = ""
)
$Root = Split-Path -Parent $PSCommandPath; . "$Root\lib\common.ps1"
Require-Tool git

$dirs = Get-ChildItem -LiteralPath $RootDir -Directory -Recurse -Depth 2
foreach($d in $dirs){
  $repo = $d.FullName
  if (-not (Test-Path (Join-Path $repo ".git"))) { continue }
  $dirty = & git -C $repo status --porcelain
  if ($dirty){ Warn "skip dirty repo: $repo"; continue }
  Info "update: $repo"
  & git -C $repo fetch --all --prune | Out-Null
  if ($Branch) {
    & git -C $repo checkout $Branch | Out-Null
  }
  & git -C $repo pull --ff-only | Out-Null
}
Ok "git repos updated"
