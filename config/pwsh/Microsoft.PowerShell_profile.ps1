#region Initial Setup & Preferences
$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'
[console]::InputEncoding = [console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
#endregion

#region Safe Module Import Function
function Import-ModuleSafely {
    param (
        [string]$ModuleName,
        [switch]$AllowClobber = $false,
        [switch]$Required = $false
    )
    try {
        if (!(Get-Module -ListAvailable -Name $ModuleName)) {
            Write-Host "Attempting to install module '$ModuleName'..." -ForegroundColor Yellow
            Install-Module -Name $ModuleName -Scope CurrentUser -Force -AllowClobber:$AllowClobber -SkipPublisherCheck -ErrorAction Stop
        }
        Import-Module -Name $ModuleName -DisableNameChecking -ErrorAction Stop
    }
    catch {
        $errorMessage = "Failed to load or install module '$ModuleName'. Error: $_"
        if ($Required) {
            throw $errorMessage
        }
        else {
            Write-Warning $errorMessage
        }
    }
}
#endregion

#region Core Module Imports
$ModulesToLoad = @{
    'posh-git'       = @{ Required = $true;  AllowClobber = $false }
    'Terminal-Icons' = @{ Required = $true;  AllowClobber = $false }
    'PSFzf'          = @{ Required = $false; AllowClobber = $false }
    'zoxide'         = @{ Required = $false; AllowClobber = $false }
}

foreach ($moduleEntry in $ModulesToLoad.GetEnumerator()) {
    Import-ModuleSafely -ModuleName $moduleEntry.Key -Required:$moduleEntry.Value.Required -AllowClobber:$moduleEntry.Value.AllowClobber
}
#endregion

#region Oh-My-Posh Initialization
try {
    # --- !!! --- REPLACE THIS LINE WITH YOUR MINIMAL OH-MY-POSH THEME PATH/URL --- !!! ---
    oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\your-minimal-theme.omp.json" | Invoke-Expression
    # --- !!! --- REPLACE THE LINE ABOVE --- !!! ---
}
catch {
    Write-Warning "Failed to initialize Oh-My-Posh with the specified theme. Error: $_"
    function prompt { "$PWD> " } # Basic fallback prompt
}
#endregion

#region PSReadLine Configuration
Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -BellStyle None
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -HistoryNoDuplicates
Set-PSReadLineOption -AddToHistoryHandler {
    param($line)
    $sensitive = @('password', 'secret', 'token', 'apikey', 'connectionstring')
    $hasSensitive = $sensitive | Where-Object { $line -match $_ }
    return ($null -eq $hasSensitive)
}
Set-PSReadLineOption -MaximumHistoryCount 10000

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

$KeyBindings = @{
    'Tab'             = 'MenuComplete'
    'UpArrow'         = 'HistorySearchBackward'
    'DownArrow'       = 'HistorySearchForward'
    'Ctrl+LeftArrow'  = 'BackwardWord'
    'Ctrl+RightArrow' = 'ForwardWord'
    'Ctrl+Backspace'  = 'BackwardKillWord'
    'Ctrl+Delete'     = 'KillWord'
    'Ctrl+w'          = 'BackwardKillWord'
    'Alt+d'           = 'KillWord'
    'Ctrl+u'          = 'BackwardKillLine'
    'Ctrl+k'          = 'KillLine'
    'Ctrl+l'          = 'ClearScreen'
    'Ctrl+/'          = 'Undo'
    'Ctrl+d'          = 'DeleteChar'
    'Ctrl+z'          = 'Undo'
    'Ctrl+y'          = 'Yank'
}

foreach ($binding in $KeyBindings.GetEnumerator()) {
    if ($binding.Key -match '^(Ctrl|Alt)\+') {
        Set-PSReadLineKeyHandler -Chord $binding.Key -Function $binding.Value -BriefDescription $binding.Value
    } else {
        Set-PSReadLineKeyHandler -Key $binding.Key -Function $binding.Value -BriefDescription $binding.Value
    }
}
#endregion

#region FZF Configuration & Functions
$env:FZF_DEFAULT_OPTS = @"
--height 40% --layout=reverse --border --inline-info
--preview 'bat --style=numbers --color=always --line-range :500 {}'
--color=dark --color=fg:-1,bg:-1,hl:#5fff87,fg+:#ffffff,bg+:#383a42,hl+:#5fff87
--color=info:#afaf87,prompt:#5fff87,pointer:#af5fff,marker:#af5fff,spinner:#af5fff
"@

Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'

function Search-CodeRg {
    param(
        [Parameter(Mandatory)]
        [string]$Pattern,
        [string]$Path = ".",
        [string]$FileType,
        [switch]$CaseSensitive
    )
    if (-not (Get-Command rg -ErrorAction SilentlyContinue)) { Write-Warning "ripgrep (rg) is not installed or not in PATH."; return }
    if (-not (Get-Command fzf -ErrorAction SilentlyContinue)) { Write-Warning "fzf is not installed or not in PATH."; return }

    $rgArgs = @('--color=always', '--line-number')
    if ($FileType) { $rgArgs += "-t$FileType" }
    if (!$CaseSensitive) { $rgArgs += '-i' }

    & rg $rgArgs $Pattern $Path |
        fzf --ansi `
            --delimiter : `
            --preview 'bat --style=numbers --color=always --highlight-line {2} {1}' `
            --preview-window 'up,60%,border-bottom'
}
Set-Alias -Name rgf -Value Search-CodeRg -Option AllScope

function Edit-FileFzf {
    if (-not (Get-Command fzf -ErrorAction SilentlyContinue)) { Write-Warning "fzf is not installed or not in PATH."; return }
    if (-not (Get-Command $global:EDITOR -ErrorAction SilentlyContinue)) { Write-Warning "$global:EDITOR is not installed or not in PATH."; return }
    $file = Get-ChildItem -Recurse -File | Select-Object -ExpandProperty FullName | fzf
    if ($file) { & $global:EDITOR $file }
}
Set-Alias -Name ef -Value Edit-FileFzf -Option AllScope

function Set-LocationFzf {
    if (-not (Get-Command fzf -ErrorAction SilentlyContinue)) { Write-Warning "fzf is not installed or not in PATH."; return }
    $dir = Get-ChildItem -Recurse -Directory | Select-Object -ExpandProperty FullName | fzf
    if ($dir) { Set-Location -Path $dir }
}
Set-Alias -Name cdf -Value Set-LocationFzf -Option AllScope
#endregion

#region Zoxide Initialization
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell --hook prompt --no-aliases) })
}
else {
    Write-Warning "zoxide command not found. Consider installing it."
}
#endregion

#region Environment Variables
$env:GIT_SSH = "C:\Windows\system32\OpenSSH\ssh.exe"
$env:NVM_HOME = "$env:APPDATA\nvm"
$env:NVM_SYMLINK = "$env:PROGRAMFILES\nodejs"

$global:EDITOR = if (Get-Command nvim -ErrorAction SilentlyContinue) { 'nvim' }
                 elseif (Get-Command vim -ErrorAction SilentlyContinue) { 'vim' }
                 elseif (Get-Command code -ErrorAction SilentlyContinue) { 'code' }
                 else { 'notepad' }
#endregion

#region Aliases
# Navigation
Set-Alias -Name ~ -Value Set-Location -ArgumentList ~ -Option AllScope
Set-Alias -Name .. -Value Set-Location -ArgumentList .. -Option AllScope
Set-Alias -Name ... -Value Set-Location -ArgumentList ..\.. -Option AllScope
Set-Alias -Name .... -Value Set-Location -ArgumentList ..\..\.. -Option AllScope
Set-Alias -Name dt -Value Set-Location -ArgumentList ~\Desktop -Option AllScope -ErrorAction SilentlyContinue
Set-Alias -Name docs -Value Set-Location -ArgumentList ~\Documents -Option AllScope -ErrorAction SilentlyContinue
Set-Alias -Name dl -Value Set-Location -ArgumentList ~\Downloads -Option AllScope -ErrorAction SilentlyContinue

# Common Commands
Set-Alias -Name g -Value git -Option AllScope
Set-Alias -Name grep -Value Select-String -Option AllScope
Set-Alias -Name touch -Value New-Item -Option AllScope
Set-Alias -Name rm -Value Remove-Item -Option AllScope
Set-Alias -Name mv -Value Move-Item -Option AllScope
Set-Alias -Name cp -Value Copy-Item -Option AllScope
Set-Alias -Name cat -Value bat -Option AllScope -ErrorAction SilentlyContinue
if (-not (Get-Command bat -ErrorAction SilentlyContinue)) { Set-Alias -Name cat -Value Get-Content -Option AllScope }
Set-Alias -Name vim -Value $global:EDITOR -Option AllScope
Set-Alias -Name which -Value Get-Command -Option AllScope
Set-Alias -Name df -Value Get-PSDrive -Option AllScope

# Process Management
Set-Alias -Name pgrep -Value Get-Process -Option AllScope
Set-Alias -Name pkill -Value Stop-Process -Option AllScope

# Git Aliases
Set-Alias -Name gs -Value git -ArgumentList status -Option AllScope
Set-Alias -Name ga -Value git -ArgumentList add -ArgumentList . -Option AllScope

# System & Network
Set-Alias -Name ip -Value Get-NetIPConfiguration -Option AllScope

# Clipboard
Set-Alias -Name cpy -Value Set-Clipboard -Option AllScope
Set-Alias -Name pst -Value Get-Clipboard -Option AllScope

# Admin Alias
Set-Alias -Name sudo -Value admin -Option AllScope
Set-Alias -Name su -Value admin -Option AllScope
#endregion

#region Custom Functions
function admin {
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]$arguments
    )
    if (-not (Get-Command wt.exe -ErrorAction SilentlyContinue)) { Write-Error "Windows Terminal (wt.exe) not found."; return }
    $commandString = if ($arguments.Count -gt 0) { $arguments -join ' ' } else { '' }
    try {
        if ($commandString) {
             Start-Process wt.exe -Verb RunAs -ArgumentList "-p `"PowerShell`" pwsh.exe -NoExit -Command `"$commandString`""
        } else {
             Start-Process wt.exe -Verb RunAs -ArgumentList "-p `"PowerShell`""
        }
    } catch { Write-Error "Failed to start elevated process. Error: $_" }
}

function Get-DirSize {
    param([string]$Path = ".")
    try {
        $size = Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue |
            Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue
        if ($null -eq $size -or $size.Count -eq 0) { return "0 B" }
        switch($size.Sum) {
            {$_ -ge 1TB} { "{0:N2} TB" -f ($_ / 1TB); break }
            {$_ -ge 1GB} { "{0:N2} GB" -f ($_ / 1GB); break }
            {$_ -ge 1MB} { "{0:N2} MB" -f ($_ / 1MB); break }
            {$_ -ge 1KB} { "{0:N2} KB" -f ($_ / 1KB); break }
            default { "$($size.Sum) B" }
        }
    } catch { Write-Warning "Could not calculate size for '$Path'. Error: $_"; return "Error" }
}
Set-Alias -Name dus -Value Get-DirSize -Option AllScope

function Get-PubIP {
    try {
        $services = @("https://ifconfig.me/ip", "https://api.ipify.org", "https://icanhazip.com")
        foreach ($service in $services) {
            try { return (Invoke-RestMethod -Uri $service -TimeoutSec 2 -ErrorAction Stop).Trim() } catch { }
        }
        Write-Warning "Could not retrieve public IP from multiple services."
    } catch { Write-Warning "An error occurred while fetching public IP: $_" }
}

function mkcd {
    param([Parameter(Mandatory)][string]$DirectoryPath)
    try {
        $null = New-Item -ItemType Directory -Path $DirectoryPath -Force -ErrorAction Stop
        Set-Location -Path $DirectoryPath -ErrorAction Stop
    } catch { Write-Error "Failed to create or change to directory '$DirectoryPath'. Error: $_" }
}

function Flush-DnsClientCacheSafe {
    if (Get-Command Clear-DnsClientCache -ErrorAction SilentlyContinue) {
        try { Clear-DnsClientCache }
        catch { Write-Warning "Failed to flush DNS cache (may require admin rights). Error: $_" }
    } else { Write-Warning "Clear-DnsClientCache command not found." }
}
Set-Alias -Name flushdns -Value Flush-DnsClientCacheSafe -Option AllScope

function Get-Uptime {
    try {
        $os = Get-CimInstance Win32_OperatingSystem
        $uptime = (Get-Date) - $os.LastBootUpTime
        $days = $uptime.Days; $hours = $uptime.Hours; $minutes = $uptime.Minutes; $seconds = $uptime.Seconds
        Write-Host ("Uptime: {0} days, {1} hours, {2} minutes, {3} seconds" -f $days, $hours, $minutes, $seconds)
        Write-Host ("Last Boot: {0}" -f $os.LastBootUpTime.ToString("yyyy-MM-dd HH:mm:ss")) -ForegroundColor DarkGray
    } catch { Write-Warning "Could not retrieve uptime information. Error: $_" }
}
Set-Alias -Name uptime -Value Get-Uptime -Option AllScope

function which($command) {
    (Get-Command $command -ErrorAction SilentlyContinue | Select-Object -First 1).Source
}

#endregion

#region Finalization
# No final messages by default
#endregion
