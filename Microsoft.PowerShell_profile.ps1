[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

Import-Module posh-git
Import-Module -Name Terminal-Icons
Import-Module PSFzf

oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\uew.omp.json" | Invoke-Expression

Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -BellStyle None
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineKeyHandler -Key Tab -Function Complete
Set-PSReadLineKeyHandler -Key Ctrl+LeftArrow -Function BackwardWord
Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function ForwardWord
Set-PSReadLineKeyHandler -Key Ctrl+Backspace -Function BackwardKillWord
Set-PSReadLineKeyHandler -Key Ctrl+Delete -Function KillWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
Set-PSReadLineKeyHandler -Chord 'Ctrl+Shift+d' -Function ViExit

Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'

$env:GIT_SSH = "C:\Windows\system32\OpenSSH\ssh.exe"

${function:~} = { Set-Location ~ }
${function:Set-ParentLocation} = { Set-Location .. }; Set-Alias ".." Set-ParentLocation
${function:...} = { Set-Location ..\.. }
${function:....} = { Set-Location ..\..\.. }
${function:.....} = { Set-Location ..\..\..\.. }
${function:......} = { Set-Location ..\..\..\..\.. }

${function:drop} = { Set-Location ~\Documents\Dropbox }
${function:dt} = { Set-Location ~\Desktop }
${function:docs} = { Set-Location ~\Documents }
${function:dl} = { Set-Location ~\Downloads }

Set-Alias time Measure-Command
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
Set-Alias vim nvim

if (Get-Command ls.exe -ErrorAction SilentlyContinue | Test-Path) {
  Remove-Item alias:ls -ErrorAction SilentlyContinue
  ${function:ls} = { ls.exe --color @args }
  ${function:l} = { Get-ChildItem -lF @args }
  ${function:la} = { Get-ChildItem -laF @args }
  ${function:lsd} = { Get-ChildItem -Directory -Force @args }
}
else {
  ${function:la} = { Get-ChildItem -Force @args }
  ${function:lsd} = { Get-ChildItem -Directory -Force @args }
}

function which ($command) {
  Get-Command -Name $command -ErrorAction SilentlyContinue |
  Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

function mkcd { param([string]$path) New-Item $path -ItemType Directory; Set-Location $path }

function gac { param([string]$message) git add .; git commit -m $message }
function gacp { param([string]$message) gac $message; git push }

function update-all {
  choco upgrade all -y
  npm update -g
  rustup update
}

function f { explorer . }

function sudo { Start-Process powershell -Verb runAs }

function find-file { 
  param([string]$name)
  Get-ChildItem -Recurse -Filter "*${name}*" -ErrorAction SilentlyContinue | ForEach-Object FullName
}

Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
  param($commandName, $wordToComplete, $cursorPosition)
  dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
  }
}

$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

$env:NVM_HOME = "$env:APPDATA\nvm"
$env:NVM_SYMLINK = "$env:PROGRAMFILES\nodejs"
