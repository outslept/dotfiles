#Requires -Version 5.1
[CmdletBinding()]
param(
  [string]$Name = "grafana",
  [string]$Image = "grafana/grafana:latest",
  [int]$Port = 3000,
  [string]$Volume = "grafana-data",
  [string]$AdminUser = "admin",
  [Parameter(Mandatory)][string]$AdminPassword
)
$Root = Split-Path -Parent $PSCommandPath; . "$Root\lib\common.ps1"
Require-Tool docker

& docker info 1>$null 2>$null
if ($LASTEXITCODE -ne 0){ Fail "Docker daemon not reachable. Start Docker Desktop." }

$cid = (& docker ps -a --filter ("name={0}" -f $Name) --format "{{.ID}}" 2>$null) | Select-Object -First 1
if ($cid){
  & docker start $Name | Out-Null
  if ($LASTEXITCODE -ne 0){ Fail "docker start failed" }
  Ok ("grafana running at http://localhost:{0}" -f $Port)
  exit 0
}

& docker volume create $Volume | Out-Null
& docker image inspect $Image 1>$null 2>$null
if ($LASTEXITCODE -ne 0){ & docker pull $Image | Out-Null }

$run = @(
  'run','-d',
  '--name', $Name,
  '-p', ("{0}:3000" -f $Port),
  '-v', ("{0}:/var/lib/grafana" -f $Volume),
  '-e', ("GF_SECURITY_ADMIN_USER={0}" -f $AdminUser),
  '-e', ("GF_SECURITY_ADMIN_PASSWORD={0}" -f $AdminPassword),
  $Image
)
$out = & docker @run 2>&1
if ($LASTEXITCODE -ne 0){ Write-Host $out; Fail "docker run failed" }

$cid2 = (& docker ps -a --filter ("name={0}" -f $Name) --format "{{.ID}}" 2>$null) | Select-Object -First 1
if (-not $cid2){ Fail "container not found after run" }

Ok ("grafana up: http://localhost:{0}  volume={1}" -f $Port,$Volume)
