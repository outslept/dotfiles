#Requires -Version 5.1
[CmdletBinding()]
param(
  [string]$Name = "redis",
  [string]$Image = "redis:7-alpine",
  [int]$Port = 6379,
  [string]$Volume = "redis-data",
  [string]$Password = "",
  [switch]$AppendOnly
)
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSCommandPath; . "$Root\lib\common.ps1"
Require-Tool docker

& docker info 1>$null 2>$null
if ($LASTEXITCODE -ne 0) { Fail "Docker daemon not reachable. Start Docker Desktop and retry." }

$cid = (& docker ps -a --filter ("name={0}" -f $Name) --format "{{.ID}}" 2>$null) | Select-Object -First 1
if ($cid) {
  & docker start $Name | Out-Null
  if ($LASTEXITCODE -ne 0) { Fail "docker start failed" }
  Ok ("redis running: name={0} port={1} volume={2}" -f $Name,$Port,$Volume)
  exit 0
}

& docker volume create $Volume | Out-Null
& docker image inspect $Image 1>$null 2>$null
if ($LASTEXITCODE -ne 0) { & docker pull $Image | Out-Null }

# auto-detect appendonly.aof
if (-not $AppendOnly) {
  $check = & docker run --rm -v ("{0}:/data" -f $Volume) alpine sh -c "test -f /data/appendonly.aof"
  if ($LASTEXITCODE -eq 0) { $AppendOnly = $true }
}

$runArgs = @(
  'run','-d',
  '--name', $Name,
  '-p', ("{0}:6379" -f $Port),
  '-v', ("{0}:/data" -f $Volume),
  $Image
)
$redisCmd = @('redis-server')
if ($AppendOnly) { $redisCmd += @('--appendonly','yes') }
if ($Password -ne "") { $redisCmd += @('--requirepass', $Password) }
$runArgs += $redisCmd

$out = & docker @runArgs 2>&1
if ($LASTEXITCODE -ne 0) { Write-Host $out; Fail "docker run failed" }

$cid2 = (& docker ps -a --filter ("name={0}" -f $Name) --format "{{.ID}}" 2>$null) | Select-Object -First 1
if (-not $cid2) { Fail "container not found after run" }

Ok ("redis up: name={0} port={1} volume={2}" -f $Name,$Port,$Volume)
