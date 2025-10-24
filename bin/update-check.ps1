#Requires -Version 5.1
param(
  [ValidateSet('winget','scoop','all')][string]$Managers='all',
  [ValidateSet('table','json')][string]$Format='table'
)
$Root = Split-Path -Parent $PSCommandPath; . "$Root\lib\common.ps1"

$result = [ordered]@{}

if ($Managers -in @('winget','all') -and (Get-Command winget -ErrorAction SilentlyContinue)){
  $wg = & winget upgrade --accept-source-agreements
  $result['winget_raw'] = $wg
}

if ($Managers -in @('scoop','all') -and (Get-Command scoop -ErrorAction SilentlyContinue)){
  $sc = & scoop status
  $result['scoop_raw'] = $sc
}

if ($Format -eq 'json'){
  $result | ConvertTo-Json -Depth 4
} else {
  if ($result.winget_raw){ "== winget =="; $result.winget_raw }
  if ($result.scoop_raw){  "== scoop  =="; $result.scoop_raw }
}
