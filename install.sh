#!/usr/bin/env bash
# ~/Projects/dotfiles/install.sh
# One-command setup for dotfiles and bootstrap

set -euo pipefail

DOTFILES="$HOME/Projects/dotfiles"

echo "🔹 Installing dotfiles..."
for f in .bashrc .bash_profile; do
    ln -sf "$DOTFILES/$f" "$HOME/$f"
done

mkdir -p "$HOME/.config"
mkdir -p "$DOTFILES/bash"
mkdir -p "$DOTFILES/pkgbuilds"

# Source the new bashrc
source "$HOME/.bashrc"

echo "🔹 Dotfiles linked. You can now run:"
echo "    bootstrap"
echo "to install all packages from your PKGBUILD definitions."

