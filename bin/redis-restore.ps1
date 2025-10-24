#Requires -Version 5.1
[CmdletBinding(SupportsShouldProcess=$true)]
param(
  [string]$Container = "",
  [string]$Volume = "",
  [Parameter(Mandatory)][string]$File,
  [switch]$Force,
  [switch]$Restart
)
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSCommandPath; . "$Root\lib\common.ps1"
Require-Tool docker

if (-not $Container -and -not $Volume) { Fail "specify -Container or -Volume" }
$path = (Resolve-Path -LiteralPath $File).Path
$ext = [System.IO.Path]::GetExtension($path).ToLowerInvariant()

if (-not $Volume -and $Container) {
  $tmpl = '{{range .Mounts}}{{if eq .Destination "/data"}}{{if eq .Type "volume"}}{{.Name}}{{end}}{{end}}{{end}}'
  $Volume = (& docker inspect $Container --format $tmpl 2>$null) | Select-Object -First 1
  if (-not $Volume) { Fail "cannot resolve /data volume from container '$Container'" }
}

if ($Container -and $Restart) { & docker stop $Container | Out-Null }
if (-not $Force) { Fail "destructive restore; pass -Force to proceed" }

$hostDir = (Resolve-Path (Split-Path -Parent $path)).Path
$fileName = (Split-Path -Leaf $path)

if ($ext -in @('.gz','.tgz','.tar')) {
  $restoreSh = ('first=$(tar tzf /backup/{0} | head -n 1); case "$first" in data/*) rm -rf /data/*; tar xzf /backup/{0} -C /data --strip-components=1 ;; *) rm -rf /data/*; tar xzf /backup/{0} -C /data ;; esac' -f $fileName)
  $cmd = @(
    'run','--rm',
    '-v',("{0}:/data" -f $Volume),
    '-v',("{0}:/backup" -f $hostDir),
    'alpine','sh','-c', $restoreSh
  )
  if ($PSCmdlet.ShouldProcess($Volume,"restore from archive $fileName")) {
    $out = & docker @cmd 2>&1
    $code = $LASTEXITCODE
    if ($code -ne 0) { Write-Host $out; Fail ("restore failed (exit={0})" -f $code) }
  }
} elseif ($ext -eq '.rdb') {
