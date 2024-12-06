#region
$ErrorActionPreference = 'SilentlyContinue'
$ProgressPreference = 'SilentlyContinue'
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
#endregion

#region Environment Setup
[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

# Safe module import function with error handling
function Import-ModuleSafely {
    param (
        [string]$ModuleName,
        [switch]$AllowClobber,
        [switch]$Required
    )
    try {
        if (!(Get-Module -ListAvailable -Name $ModuleName)) {
            Write-Host "Installing module '$ModuleName'..." -ForegroundColor Yellow
            Install-Module -Name $ModuleName -Scope CurrentUser -Force -AllowClobber:$AllowClobber -ErrorAction Stop
        }
        Import-Module -Name $ModuleName -DisableNameChecking -ErrorAction Stop
        Write-Host "Successfully loaded $ModuleName" -ForegroundColor Green
    }
    catch {
        $message = "Failed to import module $ModuleName`: $_"
        if ($Required) {
            throw $message
        }
        else {
            Write-Warning $message
        }
    }
}
#endregion

#region Module Imports
$RequiredModules = @{
    'posh-git' = $true      # Required
    'Terminal-Icons' = $true # Required
    'PSFzf' = $false        # Optional
}

foreach ($module in $RequiredModules.GetEnumerator()) {
    Import-ModuleSafely -ModuleName $module.Key -Required:$module.Value
}

# Initialize oh-my-posh
try {
    if (Get-Command oh-my-posh -ErrorAction Stop) {
        oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\uew.omp.json" | Invoke-Expression
    }
}
catch {
    Write-Warning "Failed to initialize oh-my-posh: $_"
}
#endregion

#region PSReadLine Configuration
# Core settings
Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -BellStyle None
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView

# Color scheme
Set-PSReadLineOption -Colors @{
    Command = 'Magenta'
    Parameter = 'DarkGray'
    Operator = 'DarkGray'
    Variable = 'Green'
    String = 'DarkCyan'
    Number = 'DarkGreen'
    Member = 'DarkGreen'
    Type = 'DarkYellow'
    Comment = 'DarkGray'
}

# Keybindings
$KeyBindings = @{
    'Tab' = 'MenuComplete'
    'UpArrow' = 'HistorySearchBackward'
    'DownArrow' = 'HistorySearchForward'
    'Ctrl+LeftArrow' = 'BackwardWord'
    'Ctrl+RightArrow' = 'ForwardWord'
    'Ctrl+Backspace' = 'BackwardKillWord'
    'Ctrl+Delete' = 'KillWord'
}

foreach ($binding in $KeyBindings.GetEnumerator()) {
    Set-PSReadLineKeyHandler -Key $binding.Key -Function $binding.Value
}

# Advanced keybindings
$AdvancedKeyBindings = @{
    'Ctrl+w' = 'BackwardKillWord'
    'Alt+d' = 'KillWord'
    'Ctrl+u' = 'BackwardDeleteLine'
    'Ctrl+k' = 'ForwardDeleteLine'
    'Ctrl+l' = 'ClearScreen'
    'Ctrl+/' = 'Undo'
}

foreach ($binding in $AdvancedKeyBindings.GetEnumerator()) {
    Set-PSReadLineKeyHandler -Chord $binding.Key -Function $binding.Value
}
#endregion

#region FZF Configuration
# Default options
$env:FZF_DEFAULT_OPTS = @"
--height 40%
--layout=reverse
--border
--inline-info
--preview 'bat --style=numbers --color=always --line-range :500 {}'
"@

# Configure PSFzf
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'
#endregion

#region Path and Environment
$env:GIT_SSH = "C:\Windows\system32\OpenSSH\ssh.exe"
$env:NVM_HOME = "$env:APPDATA\nvm"
$env:NVM_SYMLINK = "$env:PROGRAMFILES\nodejs"
#endregion

#region Aliases
# Navigation
${function:~} = { Set-Location ~ }
${function:Set-ParentLocation} = { Set-Location .. }
Set-Alias ".." Set-ParentLocation
${function:...} = { Set-Location ..\.. }
${function:....} = { Set-Location ..\..\.. }

# Common utilities
Set-Alias time Measure-Command
Set-Alias g git
Set-Alias grep findstr
Set-Alias touch New-Item
Set-Alias rm Remove-Item
Set-Alias which Get-Command
Set-Alias cat bat
Set-Alias mv Move-Item
Set-Alias vim nvim

# Directory shortcuts
${function:dt} = { Set-Location ~\Desktop }
${function:docs} = { Set-Location ~\Documents }
${function:dl} = { Set-Location ~\Downloads }
#endregion

#region Custom Functions
# Directory and file management
function Get-DirSize {
    param([string]$Path = ".")
    $size = Get-ChildItem -Path $Path -Recurse -ErrorAction SilentlyContinue |
        Measure-Object -Property Length -Sum

    switch($size.Sum) {
        {$_ -gt 1TB} {"{0:N2} TB" -f ($_ / 1TB); break}
        {$_ -gt 1GB} {"{0:N2} GB" -f ($_ / 1GB); break}
        {$_ -gt 1MB} {"{0:N2} MB" -f ($_ / 1MB); break}
        {$_ -gt 1KB} {"{0:N2} KB" -f ($_ / 1KB); break}
        default {"$_ B"}
    }
}

# Git utilities
function New-GitRepo {
    param(
        [Parameter(Mandatory)]
        [string]$Name,
        [string]$Branch = "main"
    )
    New-Item -ItemType Directory -Path $Name
    Set-Location $Name
    git init
    git checkout -b $Branch
    Write-Host "Git repository '$Name' created with branch '$Branch'" -ForegroundColor Green
}

# Search utilities
function Search-CodeRg {
    param(
        [Parameter(Mandatory)]
        [string]$Pattern,
        [string]$Path = ".",
        [string]$FileType,
        [switch]$CaseSensitive
    )
    $rgArgs = @('--color=always', '--line-number')
    if ($FileType) { $rgArgs += "-t$FileType" }
    if (!$CaseSensitive) { $rgArgs += '-i' }

    & rg $rgArgs $Pattern $Path |
        fzf --ansi --preview 'bat --style=numbers --color=always --highlight-line {2} {1}'
}
Set-Alias -Name rgf -Value Search-CodeRg

# FZF enhanced functions
function Edit-FileFzf {
    $file = Get-ChildItem -Recurse | Where-Object { !$_.PSIsContainer } |
        Select-Object -ExpandProperty FullName | fzf
    if ($file) { vim $file }
}
Set-Alias -Name ef -Value Edit-FileFzf

function Set-LocationFzf {
    $dir = Get-ChildItem -Recurse -Directory |
        Select-Object -ExpandProperty FullName | fzf
    if ($dir) { Set-Location $dir }
}
Set-Alias -Name cdf -Value Set-LocationFzf
#endregion

#region Development Utilities
# Docker utilities
function Get-DockerStatus {
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
}

function Remove-DockerAll {
    docker stop $(docker ps -aq)
    docker rm $(docker ps -aq)
    docker rmi $(docker images -q)
}

# Git utilities
function Get-GitStatus {
    git status -sb
}

function Update-GitRepo {
    param(
        [string]$Branch = "main"
    )
    git fetch
    git pull origin $Branch
    git submodule update --init --recursive
}

function New-GitBranch {
    param(
        [Parameter(Mandatory)]
        [string]$Name,
        [string]$Base = "main"
    )
    git checkout -b $Name $Base
}

# Development environment utilities
function Start-DevEnv {
    param(
        [string]$ProjectPath = ".",
        [switch]$Docker,
        [switch]$Node
    )

    Push-Location $ProjectPath

    if ($Docker) {
        docker-compose up -d
    }

    if ($Node) {
        if (Test-Path package.json) {
            npm install
            npm start
        }
    }

    nvim .
}

# Quick project navigation
$ProjectsRoot = "~/Projects"  # Customize this path
function Set-ProjectLocation {
    if (!(Test-Path $ProjectsRoot)) {
        New-Item -ItemType Directory -Path $ProjectsRoot
    }
    Push-Location $ProjectsRoot
    $project = Get-ChildItem -Directory | ForEach-Object Name | fzf
    if ($project) {
        Set-Location $project
    }
    else {
        Pop-Location
    }
}
Set-Alias proj Set-ProjectLocation

# Performance monitoring
function Get-ProcessMemory {
    Get-Process |
        Sort-Object WorkingSet64 -Descending |
        Select-Object -First 10 Name, @{N='Memory (MB)';E={[math]::Round($_.WorkingSet64 / 1MB, 2)}}
}

# Development server
function Start-DevServer {
    param(
        [int]$Port = 8000,
        [string]$Path = "."
    )
    $python = Get-Command python -ErrorAction SilentlyContinue
    if ($python) {
        Start-Process python -ArgumentList "-m", "http.server", $Port -WorkingDirectory $Path
        Start-Process "http://localhost:$Port"
    }
    else {
        Write-Warning "Python is not installed"
    }
}
#endregion

#region Error Handling
# Global error handler
$Global:Error.Clear()
$ErrorActionPreference = 'Continue'

# Error logging
$ErrorLogPath = Join-Path $env:USERPROFILE "powershell_errors.log"
$Global:ErrorView = 'CategoryView'

# Log errors to file
$null = New-Item -ItemType File -Path $ErrorLogPath -Force
Register-EngineEvent PowerShell.Exiting -Action {
    Get-Error | Out-File $ErrorLogPath -Append
} | Out-Null
#endregion

#region Startup
# Load Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}

# Configure ls command
if (Get-Command ls.exe -ErrorAction SilentlyContinue | Test-Path) {
    Remove-Item alias:ls -ErrorAction SilentlyContinue
    ${function:ls} = { ls.exe --color @args }
    ${function:ll} = { ls.exe -l --color @args }
    ${function:la} = { ls.exe -la --color @args }
} else {
    ${function:ll} = { Get-ChildItem -Force @args }
    ${function:la} = { Get-ChildItem -Force @args }
}
#endregion
