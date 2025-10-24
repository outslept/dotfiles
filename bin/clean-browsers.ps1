#Requires -Version 5.1
[CmdletBinding(SupportsShouldProcess=$true)]
param(
  [ValidateSet('all','chrome','edge','brave','opera','firefox')][string]$Target='all'
)
$Root = Split-Path -Parent $PSCommandPath; . "$Root\lib\common.ps1"

$procs = switch ($Target) {
  'all'     { @('chrome.exe','msedge.exe','firefox.exe','opera.exe','brave.exe') }
  'chrome'  { @('chrome.exe') }
  'edge'    { @('msedge.exe') }
  'brave'   { @('brave.exe') }
  'opera'   { @('opera.exe') }
  'firefox' { @('firefox.exe') }
}
foreach($name in $procs){
  & taskkill /F /T /IM $name 1>$null 2>$null
}

$cleared = $false
$local = $env:LOCALAPPDATA; $roam = $env:APPDATA
function rmIf([string]$p){
  if (Test-Path $p -PathType Container){
    if ($PSCmdlet.ShouldProcess($p,"remove")){
      Remove-Item $p -Recurse -Force -ErrorAction SilentlyContinue
      return $true
    }
  }
  $false
}

if ($local -and ($Target -in @('all','chrome'))){
  $root = Join-Path $local 'Google\Chrome\User Data'
  if (Test-Path $root){ Get-ChildItem $root -Directory | %{
    foreach($sub in 'Cache','Code Cache','GPUCache','Service Worker\CacheStorage'){ $cleared = (rmIf (Join-Path $_.FullName $sub)) -or $cleared }
  }}
}
if ($local -and ($Target -in @('all','edge'))){
  $root = Join-Path $local 'Microsoft\Edge\User Data'
  if (Test-Path $root){ Get-ChildItem $root -Directory | %{
    foreach($sub in 'Cache','Code Cache','GPUCache','Service Worker\CacheStorage'){ $cleared = (rmIf (Join-Path $_.FullName $sub)) -or $cleared }
  }}
}
if ($local -and ($Target -in @('all','brave'))){
  $root = Join-Path $local 'BraveSoftware\Brave-Browser\User Data'
  if (Test-Path $root){ Get-ChildItem $root -Directory | %{
    foreach($sub in 'Cache','Code Cache','GPUCache','Service Worker\CacheStorage'){ $cleared = (rmIf (Join-Path $_.FullName $sub)) -or $cleared }
  }}
}
if ($roam -and ($Target -in @('all','opera'))){
  foreach($sub in 'Cache','Code Cache','GPUCache','Service Worker\CacheStorage'){
    $cleared = (rmIf (Join-Path $roam "Opera Software\Opera Stable\$sub")) -or $cleared
  }
}
if ($local -and ($Target -in @('all','firefox'))){
  $ff = Join-Path $local 'Mozilla\Firefox\Profiles'
  if (Test-Path $ff){ Get-ChildItem $ff -Directory | %{
    $cleared = (rmIf (Join-Path $_.FullName 'cache2')) -or $cleared
  }}
}

if ($cleared){ Ok "Cleared browser caches" } else { Info "no caches found"; exit 2 }
