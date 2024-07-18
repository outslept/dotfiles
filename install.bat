@echo off

set VSCODE_HOME=%APPDATA%\Code\User

if not exist "%VSCODE_HOME%" mkdir "%VSCODE_HOME%"
if not exist "%VSCODE_HOME%\snippets" mkdir "%VSCODE_HOME%\snippets"

copy settings.json "%VSCODE_HOME%\"
copy keybindings.json "%VSCODE_HOME%\"

copy snippets\*.json "%VSCODE_HOME%\snippets\"

if exist .vscode\settings.json (
    if not exist "%VSCODE_HOME%\.vscode" mkdir "%VSCODE_HOME%\.vscode"
    copy .vscode\settings.json "%VSCODE_HOME%\.vscode\"
)

echo VSCode configuration installed.