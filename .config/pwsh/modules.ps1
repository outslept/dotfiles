$Base = $PSScriptRoot
try { $t = (Get-Item -LiteralPath $PSCommandPath -ErrorAction Stop).Target } catch { $t = $null }
if ($t) { $Base = Split-Path -Parent $t }

# add local Modules/ to PSModulePath (once)
$Vendor = Join-Path $Base 'Modules'
if (Test-Path $Vendor) {
    $sep   = [IO.Path]::PathSeparator
    $paths = $env:PSModulePath -split [Regex]::Escape($sep)
    if (-not ($paths -contains $Vendor)) {
        $env:PSModulePath = "$Vendor$sep$env:PSModulePath"
    }
}

# load module if installed, skip errors, import globally
function Import-IfAvailable {
    param([Parameter(Mandatory)][string]$Name)
    if (Get-Module -Name $Name) { return }
    if (Get-Module -ListAvailable -Name $Name) {
        Import-Module -Name $Name -Scope Global -DisableNameChecking -ErrorAction SilentlyContinue
    }
}

Import-IfAvailable 'PSReadLine'
Import-IfAvailable 'PSFzf'

# posh-git for git completion/status (disable its prompt to avoid conflict with oh-my-posh)
if (Get-Command git -ErrorAction SilentlyContinue) {
    Import-IfAvailable 'posh-git'
    if (Get-Module posh-git -ErrorAction SilentlyContinue) {
        $disableGitPrompt = Get-Command -Name Disable-GitPrompt -Module posh-git -ErrorAction SilentlyContinue
        if ($disableGitPrompt) { Disable-GitPrompt | Out-Null }
    }
}

# PSFzf defaults and keybinding (Ctrl+r = fzf history) when PSFzf is loaded
if (Get-Module PSFzf -ErrorAction SilentlyContinue) {
    if (-not $env:FZF_DEFAULT_OPTS) { $env:FZF_DEFAULT_OPTS = '--height 40% --layout=reverse --border --color=dark' }
    Set-PsFzfOption -PSReadlineChordHistory 'Ctrl+r'
    # Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' # fzf files
    # Set-PsFzfOption -PSReadlineChordReverseHistory 'Alt+c' # cd via fzf
}
