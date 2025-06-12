$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'
[console]::InputEncoding = [console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

function Import-ModuleSafely {
    param([string]$ModuleName, [switch]$Required)
    if (Get-Module $ModuleName) { return }

    if (!(Get-Module -ListAvailable $ModuleName)) {
        Install-Module $ModuleName -Scope CurrentUser -Force -AllowClobber -SkipPublisherCheck -ErrorAction Stop
    }
    Import-Module $ModuleName -DisableNameChecking -ErrorAction $(if ($Required) { 'Stop' } else { 'SilentlyContinue' })
}

Import-ModuleSafely 'posh-git' -Required
Import-ModuleSafely 'PSFzf'

$OMP_THEME_URL = "https://raw.githubusercontent.com/outslept/dotfiles/master/config/pwsh/outslept.omp.json"

if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    (Invoke-WebRequest -Uri $OMP_THEME_URL -UseBasicParsing).Content | Set-Content -Path "$env:TEMP\outslept.omp.json"
    oh-my-posh init pwsh --config "$env:TEMP\outslept.omp.json" | Invoke-Expression
}

Set-PSReadLineOption -EditMode Emacs -BellStyle None -PredictionSource History -PredictionViewStyle ListView -HistoryNoDuplicates -MaximumHistoryCount 10000

Set-PSReadLineOption -AddToHistoryHandler {
    param($line)
    $sensitivePatterns = @(
        'password', 'passwd'
        'secret', 'key', 'token', 'auth'
        'apikey', 'api_key', 'api-key'
        'connectionstring', 'connstr', 'dsn'
        'credential', 'cred', 'login'
    )
    return !($sensitivePatterns | Where-Object { $line -match $_ })
}

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

@{
    'Tab' = 'MenuComplete'
    'UpArrow' = 'HistorySearchBackward'
    'DownArrow' = 'HistorySearchForward'
    'Ctrl+LeftArrow' = 'BackwardWord'
    'Ctrl+RightArrow' = 'ForwardWord'
    'Ctrl+Backspace' = 'BackwardKillWord'
    'Ctrl+Delete' = 'KillWord'
    'Ctrl+w' = 'BackwardKillWord'
    'Alt+d' = 'KillWord'
    'Ctrl+u' = 'BackwardKillLine'
    'Ctrl+k' = 'KillLine'
    'Ctrl+l' = 'ClearScreen'
    'Ctrl+d' = 'DeleteChar'
    'Ctrl+z' = 'Undo'
    'Ctrl+y' = 'Yank'
}.GetEnumerator() | ForEach-Object {
    Set-PSReadLineKeyHandler -Key $_.Key -Function $_.Value -ErrorAction SilentlyContinue
}

if (Get-Module PSFzf -ErrorAction SilentlyContinue) {
    $env:FZF_DEFAULT_OPTS = '--height 40% --layout=reverse --border --inline-info --preview "bat --style=numbers --color=always --line-range :500 {}" --color=dark --color=fg:-1,bg:-1,hl:#5fff87,fg+:#ffffff,bg+:#383a42,hl+:#5fff87 --color=info:#afaf87,prompt:#5fff87,pointer:#af5fff,marker:#af5fff,spinner:#af5fff'
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'
}

$global:EDITOR = @('nvim', 'vim', 'code', 'notepad') | Where-Object { Get-Command $_ -ErrorAction SilentlyContinue } | Select-Object -First 1

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell --hook prompt --no-aliases | Out-String) })
}

function ~ { Set-Location ~ }
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }
function dt { Set-Location ~\Desktop }
function docs { Set-Location ~\Documents }
function dl { Set-Location ~\Downloads }

function mkcd {
    param([Parameter(Mandatory)][string]$Path)
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    Set-Location -Path $Path
}

function which($cmd) {
    (Get-Command $cmd -ErrorAction SilentlyContinue).Source
}

function admin {
    param([Parameter(ValueFromRemainingArguments=$true)][string[]]$args)
    Start-Process wt.exe -Verb RunAs -ArgumentList $(if ($args) { "-p `"PowerShell`" pwsh.exe -NoExit -Command `"$($args -join ' ')`"" } else { "-p `"PowerShell`"" }) -ErrorAction SilentlyContinue
}

function ll { Get-ChildItem -Force }
function la { Get-ChildItem -Force -Hidden }

function size {
    param([string]$Path = ".")
    $bytes = (Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    switch($bytes) {
        {$_ -ge 1TB} { "{0:N2} TB" -f ($_ / 1TB) }
        {$_ -ge 1GB} { "{0:N2} GB" -f ($_ / 1GB) }
        {$_ -ge 1MB} { "{0:N2} MB" -f ($_ / 1MB) }
        {$_ -ge 1KB} { "{0:N2} KB" -f ($_ / 1KB) }
        default { "$bytes B" }
    }
}

function pubip {
    foreach ($url in "https://ifconfig.me/ip", "https://api.ipify.org", "https://icanhazip.com") {
        $ip = Invoke-RestMethod $url -TimeoutSec 3 -ErrorAction SilentlyContinue
        if ($ip) { return $ip.Trim() }
    }
    "Failed to get IP"
}

function ports {
    Get-NetTCPConnection | Where-Object State -eq Listen | Select-Object LocalAddress, LocalPort, OwningProcess | Sort-Object LocalPort
}

function procs {
    Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 Name, CPU, WorkingSet, Id
}

function reload { . $PROFILE }

function path { $env:PATH -split ';' | Sort-Object }

function uptime {
    $boot = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
    $up = (Get-Date) - $boot
    "$($up.Days)d $($up.Hours)h $($up.Minutes)m"
}

@{
    'grep' = 'Select-String'
    'touch' = 'New-Item'
    'rm' = 'Remove-Item'
    'mv' = 'Move-Item'
    'cp' = 'Copy-Item'
    'vim' = $global:EDITOR
    'df' = 'Get-PSDrive'
    'ps' = 'Get-Process'
    'kill' = 'Stop-Process'
    'ip' = 'Get-NetIPConfiguration'
    'sudo' = 'admin'
    'su' = 'admin'
    'cls' = 'Clear-Host'
    'history' = 'Get-History'
}.GetEnumerator() | ForEach-Object {
    Set-Alias -Name $_.Key -Value $_.Value -Option AllScope -ErrorAction SilentlyContinue
}
