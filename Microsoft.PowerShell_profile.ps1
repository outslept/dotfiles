# Set PowerShell to UTF-8
[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

# Import modules
Import-Module posh-git
Import-Module -Name Terminal-Icons
Import-Module PSFzf

# Define the path to your oh-my-posh configuration file
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\uew.omp.json" | Invoke-Expression

# Initialize oh-my-posh with the correct config file
oh-my-posh init pwsh --config $omp_config | Invoke-Expression

# PSReadLine settings
Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -BellStyle None
Set-PSReadLineOption -PredictionSource History

# Enable Tab completion
Set-PSReadLineKeyHandler -Key Tab -Function Complete

# Additional key bindings for better navigation
Set-PSReadLineKeyHandler -Key Ctrl+LeftArrow -Function BackwardWord
Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function ForwardWord
Set-PSReadLineKeyHandler -Key Ctrl+Backspace -Function BackwardKillWord
Set-PSReadLineKeyHandler -Key Ctrl+Delete -Function KillWord

# Ctrl+d still deletes char, but now you can use Ctrl+Shift+d to exit
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
Set-PSReadLineKeyHandler -Chord 'Ctrl+Shift+d' -Function ViExit

# Fzf settings
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'

# Environment variable for Git SSH
$env:GIT_SSH = "C:\Windows\system32\OpenSSH\ssh.exe"

# Aliases
Set-Alias ll ls
Set-Alias g git
Set-Alias grep findstr
Set-Alias touch New-Item
Set-Alias rm Remove-Item
Set-Alias which Get-Command
Set-Alias cat bat
Set-Alias mv Move-Item
Set-Alias open Invoke-Item
Set-Alias tig 'C:\Program Files\Git\usr\bin\tig.exe'
Set-Alias less 'C:\Program Files\Git\usr\bin\less.exe'

# Utility function to mimic `which` command in Unix
function which ($command) {
    Get-Command -Name $command -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

function mkcd {
    param([string]$path)
    New-Item $path -ItemType Directory
    Set-Location $path
}
# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}
