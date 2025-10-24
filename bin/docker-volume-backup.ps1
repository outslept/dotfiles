#Requires -Version 5.1
param(
  [Parameter(Mandatory)][string]$Volume,
  [string]$OutPath = ""
)
$Root = Split-Path -Parent $PSCommandPath; . "$Root\lib\common.ps1"
Require-Tool docker
$ts = (Get-Date).ToString("yyyyMMdd-HHmmss")
if (-not $OutPath){ $OutPath = Join-Path (Get-Location) ("$Volume-$ts.tar.gz") }
Ensure-Dir (Split-Path -Parent $OutPath)

$hostDir = (Resolve-Path (Split-Path -Parent $OutPath)).Path
$fileName = (Split-Path -Leaf $OutPath)
$run = @(
  'run','--rm',
  '-v',("{0}:/data:ro" -f $Volume),
  '-v',("{0}:/backup" -f $hostDir),
  'alpine','sh','-c',("cd /data && tar czf /backup/{0} ." -f $fileName)
)
if (Exec -File docker -Args $run){ Fail "volume backup failed ($LASTEXITCODE)" }
if (-not (Test-Path -LiteralPath $OutPath)){ Fail "backup file not found: $OutPath" }
Ok "backup saved: $OutPath"
