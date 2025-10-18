# Ensure PSReadLine is available
try { Import-Module PSReadLine -ErrorAction SilentlyContinue } catch {}

if (Get-Module PSReadLine -ErrorAction SilentlyContinue) {
  # - Emacd mode: familiar Ctrl+A/E/K/U, etc.
  # - No bell
  # - History-based predictions (ListView)
  # - No duplicate history entries
  Set-PSReadLineOption -EditMode Emacs `
                       -BellStyle None `
                       -PredictionSource History `
                       -PredictionViewStyle ListView `
                       -HistoryNoDuplicates `
                       -MaximumHistoryCount 5000

  # Do not store potential secrets in the history
  Set-PSReadLineOption -AddToHistoryHandler {
    param($line)
    $p = @(
      '\bpassword\b','\bpasswd\b','\bsecret\b','\btoken\b','\bapi[_-]?key\b',
      '\bconnectionstring\b','\bconnstr\b','\bdsn\b','\bcredential\b','\bcred\b','\blogin\b'
    )
    foreach ($x in $p) { if ($line -imatch $x) { return $false } }
    return $true
  }

  # Word navigation
  Set-PSReadLineKeyHandler -Key Alt+b           -Function BackwardWord # ← one word
  Set-PSReadLineKeyHandler -Key Alt+f           -Function ForwardWord # → one word
  Set-PSReadLineKeyHandler -Key Ctrl+LeftArrow  -Function BackwardWord # Windows-friendly
  Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function ForwardWord

  # Word deletion
  Set-PSReadLineKeyHandler -Key Ctrl+w       -Function BackwardKillWord # delete word to the left
  Set-PSReadLineKeyHandler -Key Ctrl+Delete  -Function KillWord # delete word to the right

  # Screen clear
  Set-PSReadLineKeyHandler -Key Ctrl+l -Function ClearScreen

  # History search
  # If PSFzf is not loaded, bind Ctrl+r to built-in reverse search.
  # If PSFzf is loaded, modules.ps1 already maps Ctrl+r to fzf history.
  if (-not (Get-Module PSFzf -ErrorAction SilentlyContinue)) {
    Set-PSReadLineKeyHandler -Key Ctrl+r -Function ReverseSearchHistory
  }
}
