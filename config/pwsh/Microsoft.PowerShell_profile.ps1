$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'
[console]::InputEncoding = [console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

$devtoolsModulesPath = "E:\.devtools\pwsh\Modules"
if (!(Test-Path $devtoolsModulesPath)) {
    New-Item -ItemType Directory -Path $devtoolsModulesPath -Force | Out-Null
}
$env:PSModulePath = "$devtoolsModulesPath;$env:PSModulePath"

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

function Get-OMPTheme {
    $themeDir = "E:\.devtools\pwsh"
    $themeFile = "$themeDir\outslept.omp.json"
    $etagFile = "$themeDir\outslept.etag"
    $url = "https://raw.githubusercontent.com/outslept/dotfiles/master/config/pwsh/outslept.omp.json"

    if (!(Test-Path $themeDir)) {
        New-Item -ItemType Directory -Path $themeDir -Force | Out-Null
    }

    $needsUpdate = $true
    $currentEtag = $null

    if (Test-Path $etagFile) {
        $savedEtag = Get-Content $etagFile -Raw -ErrorAction SilentlyContinue
    }

    try {
        $response = Invoke-WebRequest -Uri $url -Method Head -UseBasicParsing -TimeoutSec 5
        $currentEtag = $response.Headers.ETag

        if ($savedEtag -and $currentEtag -and $savedEtag.Trim() -eq $currentEtag.Trim() -and (Test-Path $themeFile)) {
            $needsUpdate = $false
        }
    } catch {
        if (Test-Path $themeFile) {
            $needsUpdate = $false
        }
    }

    if ($needsUpdate) {
        try {
            $content = (Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 10).Content
            Set-Content -Path $themeFile -Value $content -Encoding UTF8

            if ($currentEtag) {
                Set-Content -Path $etagFile -Value $currentEtag -Encoding UTF8
            }
        } catch {
            Write-Warning "Failed to download OMP theme: $($_.Exception.Message)"
            if (!(Test-Path $themeFile)) {
                return $null
            }
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
    $env:FZF_DEFAULT_OPTS = '--height 40% --layout=reverse --border --color=dark'
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f'
}

$global:EDITOR = @('nvim', 'vim', 'code', 'notepad') | Where-Object { Get-Command $_ -ErrorAction SilentlyContinue } | Select-Object -First 1

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell --hook prompt --no-aliases | Out-String) })
}

function ~ { Set-Location ~ }
function .. { Set-Location .. }
function ... { Set-Location ..\.. }

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

function pubip {
    foreach ($url in "https://ifconfig.me/ip", "https://api.ipify.org", "https://icanhazip.com") {
        $ip = Invoke-RestMethod $url -TimeoutSec 3 -ErrorAction SilentlyContinue
        if ($ip) { return $ip.Trim() }
    }
    "Failed to get IP"
}

function reload { . $PROFILE }

function path { $env:PATH -split ';' | Sort-Object }

@{
    'grep' = 'Select-String'
    'touch' = 'New-Item'
    'rm' = 'Remove-Item'
    'mv' = 'Move-Item'
    'cp' = 'Copy-Item'
    'vim' = $global:EDITOR
    'ps' = 'Get-Process'
    'kill' = 'Stop-Process'
    'sudo' = 'admin'
    'su' = 'admin'
    'cls' = 'Clear-Host'
    'history' = 'Get-History'
}.GetEnumerator() | ForEach-Object {
    Set-Alias -Name $_.Key -Value $_.Value -Option AllScope -ErrorAction SilentlyContinue
}
