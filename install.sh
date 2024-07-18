#!/bin/bash

if [[ "$OSTYPE" == "darwin"* ]]; then
    VSCODE_HOME="$HOME/Library/Application Support/Code/User"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    VSCODE_HOME="$HOME/.config/Code/User"
else
    echo "Unsupported OS: $OSTYPE"
    exit 1
fi

mkdir -p "$VSCODE_HOME"
mkdir -p "$VSCODE_HOME/snippets"

cp snippets/*.json "$VSCODE_HOME/snippets/"

if [ -f .vscode/settings.json ]; then
    mkdir -p "$VSCODE_HOME/.vscode"
    cp .vscode/settings.json "$VSCODE_HOME/.vscode/"
fi

echo "VSCode configuration installed."