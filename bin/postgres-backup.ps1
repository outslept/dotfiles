#Requires -Version 5.1
param(
  [Parameter(Mandatory)][string]$Container,
  [string]$Database = "",
  [string]$User = "postgres",
  [Parameter(Mandatory)][string]$OutPath,
  [switch]$Zip
)
$Root = Split-Path -Parent $PSCommandPath; . "$Root\lib\common.ps1"
Require-Tool docker
Ensure-Dir (Split-Path -Parent $OutPath)

if ($Database){
  $cmd = @('exec',$Container,'pg_dump','-U',$User,'-d',$Database)
} else {
  $cmd = @('exec',$Container,'pg_dumpall','-U',$User)
}
$txt = & docker @cmd
if ($LASTEXITCODE -ne 0){ Fail "pg_dump failed ($LASTEXITCODE)" }

$rawOut = $OutPath
if ($Zip){
  $tmp = [System.IO.Path]::GetTempFileName()
  Set-Content -Path $tmp -Value $txt -Encoding UTF8
  $zipPath = [System.IO.Path]::ChangeExtension($OutPath,'.zip')
  Compress-Archive -Path $tmp -DestinationPath $zipPath -Force
  Remove-Item $tmp -Force
  $rawOut = $zipPath
} else {
  Set-Content -Path $OutPath -Value $txt -Encoding UTF8
}
Ok "backup saved: $rawOut"
