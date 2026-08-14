# UTF-8 encoding fix for oh-my-posh Unicode symbols in PowerShell 7.4+
# See: https://github.com/PowerShell/PowerShell/issues/20733
# WARNING: This affects the entire session, restart terminal to reset
[console]::InputEncoding  = [System.Text.UTF8Encoding]::new()
[console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

$Base = $PSScriptRoot
try { $t = (Get-Item -LiteralPath $PSCommandPath -ErrorAction Stop).Target } catch { $t = $null }
if ($t) { $Base = Split-Path -Parent $t }
if (-not $Base -and $MyInvocation.MyCommand.Path) { $Base = Split-Path -Parent $MyInvocation.MyCommand.Path }

$modules = Join-Path $Base 'modules.ps1'
if (Test-Path $modules) { . $modules }

if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    $cfg = Join-Path $Base 'outslept.omp.json'
    if (Test-Path $cfg) { oh-my-posh init pwsh --config $cfg | Invoke-Expression }
    else { oh-my-posh init pwsh | Invoke-Expression }
}

$keys = Join-Path $Base 'keys.ps1'
if (Test-Path $keys) { . $keys }

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell --hook pwd --no-aliases | Out-String) })
}
