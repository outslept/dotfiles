$Base = $PSScriptRoot
try { $t = (Get-Item -LiteralPath $PSCommandPath -ErrorAction Stop).Target } catch { $t = $null }
if ($t) { $Base = Split-Path -Parent $t }

$Vendor = Join-Path $Base 'Modules'
if (Test-Path $Vendor) {
    $sep = [IO.Path]::PathSeparator
    if (-not (($env:PSModulePath -split [Regex]::Escape($sep)) -contains $Vendor)) {
        $env:PSModulePath = "$Vendor$sep$env:PSModulePath"
    }
}

function Import-IfAvailable { param([string]$Name) if (Get-Module $Name) { return } if (Get-Module -ListAvailable $Name) { Import-Module $Name -DisableNameChecking } }

Import-IfAvailable 'PSReadLine'
Import-IfAvailable 'PSFzf'
if (Get-Command git -ErrorAction SilentlyContinue) { Import-IfAvailable 'posh-git' }

if (Get-Module PSFzf -ErrorAction SilentlyContinue) {
    if (-not $env:FZF_DEFAULT_OPTS) { $env:FZF_DEFAULT_OPTS = '--height 40% --layout=reverse --border --color=dark' }
    Set-PsFzfOption -PSReadlineChordHistory 'Ctrl+r'
}