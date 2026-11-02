$ErrorActionPreference = "Stop"
$dir = $PSScriptRoot.Replace('\', '/')

git config --global --replace-all include.path "$dir/git-aliases.ini"
git config --global core.hooksPath "$dir/hooks"

Write-Host "done."
