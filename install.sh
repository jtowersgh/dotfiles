#!/usr/bin/env bash
# ~/Projects/dotfiles/install.sh
# One-command setup for dotfiles and bootstrap

set -euo pipefail

DOTFILES="$HOME/Projects/dotfiles"

echo "🔹 Installing dotfiles..."

# ----------------------------
# 1️⃣ Restore dotfiles symlinks
# ----------------------------
echo "🔹 Restoring dotfiles symlinks..."
bash "$DOTFILES/restore_dotfiles.sh"

# ----------------------------
# 2️⃣ Ensure basic directories exist
# ----------------------------
mkdir -p "$HOME/.config"
mkdir -p "$DOTFILES/bash"
mkdir -p "$DOTFILES/pkgbuilds"

# ----------------------------
# 3️⃣ Source the new bashrc
# ----------------------------
if [ -f "$HOME/.bashrc" ]; then
    echo "🔹 Sourcing $HOME/.bashrc..."
    source "$HOME/.bashrc"
fi

echo "🔹 Dotfiles linked. You can now run:"
echo "    bootstrap"
echo "to install all packages from your PKGBUILD definitions."

