#Requires -Version 5.1
[CmdletBinding(SupportsShouldProcess=$true)]
param(
  [Parameter(Mandatory)][string]$Volume,
  [Parameter(Mandatory)][string]$Archive,
  [switch]$Force
)
$Root = Split-Path -Parent $PSCommandPath; . "$Root\lib\common.ps1"
Require-Tool docker
$arc = (Resolve-Path -LiteralPath $Archive).Path
if (-not $Force){ Fail "destructive! use -Force to restore $Volume from $arc" }

$hostDir = (Split-Path -Parent $arc)
$fileName = (Split-Path -Leaf $arc)

$restoreSh = ('first=$(tar tzf /backup/{0} | head -n 1); case "$first" in data/*) rm -rf /data/*; tar xzf /backup/{0} -C /data --strip-components=1 ;; *) rm -rf /data/*; tar xzf /backup/{0} -C /data ;; esac' -f $fileName)
$run = @(
  'run','--rm',
  '-v',("{0}:/data" -f $Volume),
  '-v',("{0}:/backup" -f $hostDir),
  'alpine','sh','-c', $restoreSh
)
if ($PSCmdlet.ShouldProcess("$Volume","restore from $fileName")){
  if (Exec -File docker -Args $run){ Fail "volume restore failed ($LASTEXITCODE)" }
  Ok "restored $Volume from $fileName"
}
