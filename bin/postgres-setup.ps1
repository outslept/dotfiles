#Requires -Version 5.1
[CmdletBinding()]
param(
  [string]$Name = "pg",
  [string]$Image = "postgres:16",
  [Parameter(Mandatory)][string]$Password,
  [int]$Port = 5432,
  [string]$Volume = "pgdata"
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
  Ok ("postgres running: name={0} port={1} volume={2}" -f $Name,$Port,$Volume)
  exit 0
}

& docker volume create $Volume | Out-Null
& docker image inspect $Image 1>$null 2>$null
if ($LASTEXITCODE -ne 0) { & docker pull $Image | Out-Null }

$runArgs = @(
  'run','-d',
  '--name', $Name,
  '-e', ("POSTGRES_PASSWORD={0}" -f $Password),
  '-p', ("{0}:5432" -f $Port),
  '-v', ("{0}:/var/lib/postgresql/data" -f $Volume),
  $Image
)
$out = & docker @runArgs 2>&1
if ($LASTEXITCODE -ne 0) { Write-Host $out; Fail "docker run failed" }

$cid2 = (& docker ps -a --filter ("name={0}" -f $Name) --format "{{.ID}}" 2>$null) | Select-Object -First 1
if (-not $cid2) { Fail "container not found after run" }

Ok ("postgres up: name={0} port={1} volume={2}" -f $Name,$Port,$Volume)
