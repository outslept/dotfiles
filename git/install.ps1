$ErrorActionPreference = "Stop"
$dir = Split-Path -Parent $MyInvocation.MyCommand.Path
$iniPath = $dir.Replace('\', '/') + "/git-aliases.ini"
$hooksPath = $dir.Replace('\', '/') + "/hooks"

git config --global include.path "$iniPath"
git config core.hooksPath "$hooksPath"

Write-Host "done."