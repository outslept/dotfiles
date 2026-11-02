[console]::InputEncoding = [console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

if (Get-Module PSReadLine) {
    Set-PSReadLineOption -EditMode Emacs -BellStyle None -HistorySearchCursorMovesToEnd
    Set-PSReadLineKeyHandler -Key UpArrow         -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow       -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Key Tab             -Function MenuComplete
    Set-PSReadLineKeyHandler -Key Ctrl+LeftArrow  -Function BackwardWord
    Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function ForwardWord
    Set-PSReadLineKeyHandler -Key Ctrl+Backspace  -Function BackwardKillWord
    Set-PSReadLineKeyHandler -Key Ctrl+Delete     -Function KillWord
}

Import-Module PSFzf -ErrorAction SilentlyContinue
if (Get-Module PSFzf) {
    $env:FZF_DEFAULT_OPTS ??= '--height 40% --layout=reverse --border --color=dark'
    Set-PsFzfOption -PSReadlineChordHistory 'Ctrl+r' -PSReadlineChordProvider 'Alt+t'
}

if (Get-Command git -ErrorAction SilentlyContinue) {
    Import-Module posh-git -ErrorAction SilentlyContinue
}

if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    oh-my-posh init pwsh --config "$PSScriptRoot\outslept.omp.json" | Invoke-Expression
}

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    zoxide init powershell | Out-String | Invoke-Expression
}
