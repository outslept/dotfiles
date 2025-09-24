# UTF-8 encoding fix for oh-my-posh Unicode symbols in PowerShell 7.4+
# See: https://github.com/PowerShell/PowerShell/issues/20733
# WARNING: This affects the entire session, restart terminal to reset
[console]::InputEncoding = [console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

$Base = $PSScriptRoot
try { $t = (Get-Item -LiteralPath $PSCommandPath -ErrorAction Stop).Target } catch { $t = $null }
if ($t) { $Base = Split-Path -Parent $t }

if (Test-Path (Join-Path $Base '`s1')) { . (Join-Path $Base 'modules.ps1') }

if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    $cfg = Join-Path $Base 'outslept.omp.json'
    if (Test-Path $cfg) { oh-my-posh init pwsh --config $cfg | Invoke-Expression }
    else { oh-my-posh init pwsh | Invoke-Expression }
}

try {
    Set-PSReadLineOption -EditMode Emacs -BellStyle None -PredictionSource History -PredictionViewStyle ListView -HistoryNoDuplicates -MaximumHistoryCount 5000
    Set-PSReadLineOption -AddToHistoryHandler {
        param($line)
        $p = @('\bpassword\b','\bpasswd\b','\bsecret\b','\btoken\b','\bapi[_-]?key\b','\bconnectionstring\b','\bconnstr\b','\bdsn\b','\bcredential\b','\bcred\b','\blogin\b')
        foreach ($x in $p) { if ($line -imatch $x) { return $false } }
        return $true
    }
} catch {}

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell --hook pwd --no-aliases | Out-String) })
}