[console]::InputEncoding = [console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

$Item = Get-Item -LiteralPath $PSCommandPath
$Base = Split-Path -Parent ($Item.Target ?? $Item.FullName)

$Vendor = Join-Path $Base 'Modules'
if ((Test-Path $Vendor) -and ($env:PSModulePath -split [IO.Path]::PathSeparator) -notcontains $Vendor) {
    $env:PSModulePath = "$Vendor$([IO.Path]::PathSeparator)$env:PSModulePath"
}

if (Get-Module PSReadLine) {
    Set-PSReadLineOption -EditMode Emacs `
                         -BellStyle None `
                         -PredictionSource History `
                         -PredictionViewStyle ListView `
                         -HistoryNoDuplicates `
                         -MaximumHistoryCount 5000 `
                         -AddToHistoryHandler {
        param($line)
        $line -notmatch '\b(password|passwd|secret|token|api[_-]?key|connectionstring|connstr|dsn|credential|cred|login)\b'
    }

    Set-PSReadLineKeyHandler -Key Ctrl+LeftArrow  -Function BackwardWord
    Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function ForwardWord
    Set-PSReadLineKeyHandler -Key Ctrl+Backspace  -Function BackwardKillWord
    Set-PSReadLineKeyHandler -Key Ctrl+Delete     -Function KillWord
}

Import-Module PSFzf -ErrorAction SilentlyContinue
if (Get-Module PSFzf) {
    $env:FZF_DEFAULT_OPTS ??= '--height 40% --layout=reverse --border --color=dark'
    Set-PsFzfOption -PSReadlineChordHistory 'Ctrl+r'
}

if (Get-Command git -ErrorAction SilentlyContinue) {
    Import-Module posh-git -ErrorAction SilentlyContinue
}

if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    $cfg = Join-Path $Base 'outslept.omp.json'
    oh-my-posh init pwsh --config (Test-Path $cfg ? $cfg : $null) | Invoke-Expression
}

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    zoxide init powershell --no-aliases | Out-String | Invoke-Expression
}
