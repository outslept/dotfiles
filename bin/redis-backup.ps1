#Requires -Version 5.1
[CmdletBinding()]
param(
  [string]$Container = "",
  [string]$Volume = "",
  [string]$OutPath = "",
  [string]$Password = "",
  [int]$WaitSeconds = 30
)
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSCommandPath; . "$Root\lib\common.ps1"
Require-Tool docker

if (-not $Container -and -not $Volume) { Fail "specify -Container or -Volume" }

if ($Container) {
  $argsLast = @('exec', $Container, 'redis-cli')
  if ($Password) { $argsLast += @('-a', $Password) }
  $argsLast += 'LASTSAVE'
  $before = (& docker @argsLast 2>$null) | Select-Object -First 1
  $beforeInt = 0; [void][int]::TryParse(($before -as [string]), [ref]$beforeInt)

  $argsSave = @('exec', $Container, 'redis-cli')
  if ($Password) { $argsSave += @('-a', $Password) }
  $argsSave += 'BGSAVE'
  & docker @argsSave | Out-Null

  for ($i=0; $i -lt $WaitSeconds; $i++) {
    Start-Sleep 1
    $after = (& docker @argsLast 2>$null) | Select-Object -First 1
    $afterInt = 0; [void][int]::TryParse(($after -as [string]), [ref]$afterInt)
    if ($afterInt -gt $beforeInt) { break }
  }
}

if (-not $Volume -and $Container) {
  $tmpl = '{{range .Mounts}}{{if eq .Destination "/data"}}{{if eq .Type "volume"}}{{.Name}}{{end}}{{end}}{{end}}'
  $Volume = (& docker inspect $Container --format $tmpl 2>$null) | Select-Object -First 1
  if (-not $Volume) { Fail "cannot resolve /data volume from container '$Container'" }
}

$ts = (Get-Date).ToString("yyyyMMdd-HHmmss")
if (-not $OutPath) { $OutPath = Join-Path (Get-Location) ("$Volume-$ts.tar.gz") }
Ensure-Dir (Split-Path -Parent $OutPath)
$hostDir = (Resolve-Path (Split-Path -Parent $OutPath)).Path
$fileName = (Split-Path -Leaf $OutPath)

$cmd = @(
  'run','--rm',
  '-v',("{0}:/data:ro" -f $Volume),
  '-v',("{0}:/backup" -f $hostDir),
  'alpine','sh','-c',("cd /data && tar czf /backup/{0} ." -f $fileName)
)
$out = & docker @cmd 2>&1
$code = $LASTEXITCODE
if ($code -ne 0) { Write-Host $out; Fail ("volume backup failed (exit={0})" -f $code) }
if (-not (Test-Path -LiteralPath $OutPath)) { Fail "backup file not found: $OutPath" }

Ok "backup saved: $OutPath"
