#Requires -Version 5.1
$Root = Split-Path -Parent $PSCommandPath; . "$Root\lib\common.ps1"

if (Get-Command winget -ErrorAction SilentlyContinue){
  Info "winget upgrade --all"
  & winget upgrade --all --silent --accept-package-agreements --accept-source-agreements | Out-Null
}
if (Get-Command scoop -ErrorAction SilentlyContinue){
  Info "scoop update"
  & scoop update | Out-Null
  Info "scoop update *"
  & scoop update * | Out-Null
}
Ok "updates done"
