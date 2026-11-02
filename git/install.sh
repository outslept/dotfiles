#!/usr/bin/env sh
set -eu

DIR="$(cd "$(dirname "$0")" && pwd)"

git config --global --replace-all include.path "$DIR/git-aliases.ini"
git config --global core.hooksPath "$DIR/hooks"
chmod +x "$DIR/hooks/"* 2>/dev/null || true

echo "done."
