#!/bin/bash

install_extension() {
    echo "Installing extension: $1"
    code --install-extension "$1"
}

plugin_list_path="plugin-list.txt"

if [ ! -f "$plugin_list_path" ]; then
    echo "Error: Plugin list file not found: $plugin_list_path" >&2
    exit 1
fi

mapfile -t extensions < <(grep -v '^\s*$' "$plugin_list_path")

total_extensions=${#extensions[@]}
current_extension=0

for extension in "${extensions[@]}"; do
    ((current_extension++))
    progress=$((current_extension * 100 / total_extensions))

    echo -ne "Installing Extensions: $progress%\r"

    install_extension "$extension"
done

echo -e "\nAll extensions have been installed successfully!"
