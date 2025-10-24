#Requires -Version 5.1
Set-StrictMode -Version Latest

function Info([string]$m){ Write-Host $m -ForegroundColor Cyan }
function Ok([string]$m){ Write-Host $m -ForegroundColor Green }
function Warn([string]$m){ Write-Host "WARN: $m" -ForegroundColor Yellow }
function Fail([string]$m){ Write-Host "ERROR: $m" -ForegroundColor Red; exit 1 }

function Require-Tool([string]$name) {
  if (-not (Get-Command $name -ErrorAction SilentlyContinue)) { Fail "$name not found on PATH" }
}

function Exec {
  param([string]$File,[string[]]$Args,[switch]$Quiet)
  if ($Quiet){ & $File @Args | Out-Null } else { & $File @Args }
  return $LASTEXITCODE
}

function Ensure-Dir([string]$path){ New-Item -ItemType Directory -Force -Path $path | Out-Null }
