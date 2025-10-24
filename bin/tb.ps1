#Requires -Version 5.1
[CmdletBinding()]
param(
  [Parameter(Position=0)][string]$Command,
  [Parameter(ValueFromRemainingArguments=$true)][string[]]$Rest
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [Text.Encoding]::UTF8

$Root = Split-Path -Parent $PSCommandPath
. "$Root\lib\common.ps1"

if (-not $Command -or $Command -in @('-h','--help','help','/?')) {
@"
tb — toolbox

usage: tb <command> [args]

commands:
  update-check -Managers all|winget|scoop -Format table|json
  update-packages
  update-git -RootDir <dir>
  kill-port -Port <n>
  clean-browsers -Target all|chrome|edge|brave|opera|firefox
  clean-node-cache -Managers all|npm|yarn|pnpm|bun
  media-download -Url <url> [-OutDir <dir>] [-AudioOnly] [-Format mp4|mkv|mp3] [-Subs]
  postgres-setup / postgres-backup -OutPath / postgres-restore-db
  docker-volume-backup -Volume <name> -OutPath <file>
  docker-volume-restore -Volume <name> -Archive <file> -Force
  grafana-setup
  redis-setup / redis-backup -OutPath / redis-restore
"@ | Write-Host
  exit 0
}

$ScriptPath = Join-Path $Root "$Command.ps1"
if (-not (Test-Path $ScriptPath)) { Fail "unknown command: $Command" }

$pwsh = (Get-Command pwsh -ErrorAction SilentlyContinue)
if ($pwsh) {
  & $pwsh.Source '-NoProfile' '-File' $ScriptPath @Rest
} else {
  & powershell '-NoProfile' '-ExecutionPolicy' 'Bypass' '-File' $ScriptPath @Rest
}
exit $LASTEXITCODE
