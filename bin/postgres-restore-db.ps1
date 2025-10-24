#Requires -Version 5.1
param(
  [Parameter(Mandatory)][string]$Container,
  [Parameter(Mandatory)][string]$File,
  [string]$Database = "postgres",
  [string]$User = "postgres"
)
$Root = Split-Path -Parent $PSCommandPath; . "$Root\lib\common.ps1"
Require-Tool docker

$path = Resolve-Path $File
$ext = [System.IO.Path]::GetExtension($path)
$maybeTemp = $null

if ($ext -ieq '.zip'){
  $dir = Join-Path $env:TEMP ("pg-restore-" + [guid]::NewGuid())
  New-Item -ItemType Directory -Force -Path $dir | Out-Null
  Expand-Archive -Path $path -DestinationPath $dir -Force
  $cand = Get-ChildItem $dir -Filter *.sql | Sort-Object LastWriteTime -Descending | Select-Object -First 1
  if (-not $cand){ Fail "no .sql found in archive" }
  $path = $cand.FullName
  $maybeTemp = $dir
}

$bytes = Get-Content -LiteralPath $path -Raw -Encoding UTF8
$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = "docker"
$psi.Arguments = "exec -i $Container psql -U $User -d $Database"
$psi.RedirectStandardInput = $true
$psi.UseShellExecute = $false
$proc = [System.Diagnostics.Process]::Start($psi)
$proc.StandardInput.Write($bytes)
$proc.StandardInput.Close()
$proc.WaitForExit()

if ($maybeTemp){ Remove-Item $maybeTemp -Recurse -Force -ErrorAction SilentlyContinue }
if ($proc.ExitCode -ne 0){ Fail "psql restore failed ($($proc.ExitCode))" }
Ok "restore OK into db=$Database"
