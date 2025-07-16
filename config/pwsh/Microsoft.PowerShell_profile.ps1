$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

try {
    # UTF-8 encoding fix for oh-my-posh Unicode symbols in PowerShell 7.4+
    # See: https://github.com/PowerShell/PowerShell/issues/20733
    # WARNING: This affects the entire session, restart terminal to reset
    [console]::InputEncoding = [console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
} catch { }

$devtoolsModulesPath = Join-Path $env:USERPROFILE ".devtools\pwsh\Modules"
$null = New-Item -ItemType Directory -Path $devtoolsModulesPath -Force
$env:PSModulePath = "$devtoolsModulesPath;$env:PSModulePath"

function Import-ModuleSafely {
    param([string]$ModuleName)
    if (Get-Module $ModuleName) { return }

    if (!(Get-Module -ListAvailable $ModuleName)) {
        Install-Module $ModuleName -Scope CurrentUser -Force -AllowClobber
    }
    Import-Module $ModuleName -DisableNameChecking
}

if (Get-Command git -ErrorAction SilentlyContinue) {
    Import-ModuleSafely 'posh-git'
}
Import-ModuleSafely 'PSFzf'

function Get-OMPTheme {
    $themeDir = Join-Path $env:USERPROFILE ".devtools\pwsh"
    $themeFile = Join-Path $themeDir "outslept.omp.json"
    $etagFile = Join-Path $themeDir "outslept.etag"
    $url = "https://raw.githubusercontent.com/outslept/dotfiles/master/config/pwsh/outslept.omp.json"

    $null = New-Item -ItemType Directory -Path $themeDir -Force

    $needsUpdate = $true
    $savedEtag = if (Test-Path $etagFile) { (Get-Content $etagFile -Raw).Trim() }

    try {
        $response = Invoke-WebRequest -Uri $url -Method Head -UseBasicParsing -TimeoutSec 10
        $currentEtag = $response.Headers.ETag.Trim('"')
        if ($savedEtag -eq $currentEtag -and (Test-Path $themeFile)) {
            $needsUpdate = $false
        }
    } catch {
        if (Test-Path $themeFile) { $needsUpdate = $false }
    }

    if ($needsUpdate) {
        try {
            $content = (Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 15).Content
            $null = $content | ConvertFrom-Json
            Set-Content -Path $themeFile -Value $content -Encoding UTF8
            if ($currentEtag) {
                Set-Content -Path $etagFile -Value $currentEtag -Encoding UTF8
            }
        } catch {
            if (!(Test-Path $themeFile)) { return $null }
        }
    }

    return $themeFile
}

if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    $themeFile = Get-OMPTheme
    if ($themeFile) {
        oh-my-posh init pwsh --config $themeFile | Invoke-Expression
    }
}

Set-PSReadLineOption -EditMode Emacs -BellStyle None -PredictionSource History -PredictionViewStyle ListView -HistoryNoDuplicates -MaximumHistoryCount 5000

# Filter sensitive commands from PowerShell history
Set-PSReadLineOption -AddToHistoryHandler {
    param($line)
    $sensitivePatterns = @(
        '\bpassword\b', '\bpasswd\b', '\bsecret\b', '\bkey\b',
        '\btoken\b', '\bauth\b', '\bapikey\b', '\bapi[_-]key\b',
        '\bconnectionstring\b', '\bconnstr\b', '\bdsn\b',
        '\bcredential\b', '\bcred\b', '\blogin\b'
    )
    foreach ($pattern in $sensitivePatterns) {
        if ($line -imatch $pattern) { return $false }
    }
    return $true
}

Set-PSReadLineOption -Colors @{
    Command = 'Cyan'; Parameter = 'Gray'; Operator = 'Gray'
    Variable = 'Green'; String = 'Yellow'; Number = 'Magenta'
    Member = 'Green'; Type = 'Blue'; Comment = 'DarkGray'
}

@{
    'Tab' = 'MenuComplete'; 'UpArrow' = 'HistorySearchBackward'; 'DownArrow' = 'HistorySearchForward'
    'Ctrl+LeftArrow' = 'BackwardWord'; 'Ctrl+RightArrow' = 'ForwardWord'
    'Ctrl+Backspace' = 'BackwardKillWord'; 'Ctrl+Delete' = 'KillWord'
    'Ctrl+w' = 'BackwardKillWord'; 'Alt+d' = 'KillWord'
    'Ctrl+u' = 'BackwardKillLine'; 'Ctrl+k' = 'KillLine'
    'Ctrl+l' = 'ClearScreen'; 'Ctrl+d' = 'DeleteChar'
    'Ctrl+z' = 'Undo'; 'Ctrl+y' = 'Yank'
}.GetEnumerator() | ForEach-Object {
    Set-PSReadLineKeyHandler -Key $_.Key -Function $_.Value
}

if (Get-Module PSFzf -ErrorAction SilentlyContinue) {
    if (!$env:FZF_DEFAULT_OPTS) {
        $env:FZF_DEFAULT_OPTS = '--height 40% --layout=reverse --border --color=dark'
    }
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f'
}

$global:EDITOR = @('nvim', 'vim', 'code', 'notepad') | Where-Object { Get-Command $_ -ErrorAction SilentlyContinue } | Select-Object -First 1

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell --hook prompt --no-aliases | Out-String) })
}

function ~ { Set-Location ~ }
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function ll { Get-ChildItem -Force }
function reload { . $PROFILE }
function path { $env:PATH -split ';' | Sort-Object }

function mkcd {
    param([Parameter(Mandatory)][string]$Path)
    $null = New-Item -ItemType Directory -Path $Path -Force
    Set-Location -Path $Path
}

function which($cmd) {
    (Get-Command $cmd -ErrorAction SilentlyContinue).Source
}

function admin {
    param([Parameter(ValueFromRemainingArguments)][string[]]$args)
    $wtArgs = if ($args) {
        "-p `"PowerShell`" pwsh.exe -NoExit -Command `"$($args -join ' ')`""
    } else {
        "-p `"PowerShell`""
    }
    Start-Process wt.exe -Verb RunAs -ArgumentList $wtArgs
}

function pubip {
    foreach ($url in "https://ifconfig.me/ip", "https://api.ipify.org", "https://icanhazip.com") {
        try {
            $ip = Invoke-RestMethod $url -TimeoutSec 5
            if ($ip) { return $ip.ToString().Trim() }
        } catch { continue }
    }
    "Failed to get IP"
}

@{
    'grep' = 'Select-String'; 'touch' = 'New-Item'; 'rm' = 'Remove-Item'
    'mv' = 'Move-Item'; 'cp' = 'Copy-Item'; 'vim' = $global:EDITOR
    'ps' = 'Get-Process'; 'kill' = 'Stop-Process'; 'sudo' = 'admin'
    'su' = 'admin'; 'cls' = 'Clear-Host'; 'history' = 'Get-History'
}.GetEnumerator() | ForEach-Object {
    Set-Alias -Name $_.Key -Value $_.Value -Option AllScope
}
