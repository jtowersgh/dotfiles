#!/usr/bin/env bash
# ~/Projects/dotfiles/install.sh
# One-command setup for dotfiles, bootstrap, and Neovim plugins

set -euo pipefail

DOTFILES="$HOME/Projects/dotfiles"

# ----------------------------
# 1️⃣ Restore dotfiles symlinks
# ----------------------------
echo "🔹 Restoring dotfiles..."
bash "$DOTFILES/scripts/restore_dotfiles.sh"

# ----------------------------
# 2️⃣ Ensure basic directories exist
# ----------------------------
mkdir -p "$HOME/.config"
mkdir -p "$DOTFILES/bash"
mkdir -p "$DOTFILES/pkgbuilds"

# ----------------------------
# 3️⃣ Install essential system packages
# ----------------------------
echo "🔹 Installing essential packages: git neovim base-devel"
sudo pacman -S --noconfirm git neovim base-devel

# ----------------------------
# 4️⃣ Source the new bashrc (to get bootstrap alias/function)
# ----------------------------
if [ -f "$HOME/.bashrc" ]; then
    echo "🔹 Sourcing $HOME/.bashrc..."
    source "$HOME/.bashrc"
fi

# ----------------------------
# 5️⃣ Ensure packer.nvim is installed
# ----------------------------
PACKER_DIR="$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim"
if [ ! -d "$PACKER_DIR" ]; then
    echo "📦 Installing packer.nvim..."
    git clone --depth 1 https://github.com/wbthomason/packer.nvim "$PACKER_DIR"
fi

# ----------------------------
# 6️⃣ Run PackerInstall once to ensure all plugins exist
# ----------------------------
echo "🔹 Installing Neovim plugins (first-time PackerInstall)..."
nvim --headless +PackerInstall +qa

# ----------------------------
# 7️⃣ Run bootstrap to install PKGBUILD packages
# ----------------------------
echo "🔹 Running PKGBUILD-aware bootstrap..."
bootstrap || echo "⚠ 'bootstrap' not found: open a new terminal or run 'exec bash' first"

# ----------------------------
# 8️⃣ Sync plugins to ensure up-to-date
# ----------------------------
echo "🔹 Running PackerSync to update plugins..."
nvim --headless +PackerSync +qa

echo "✅ Setup complete! You can now open Neovim with all plugins installed."
echo "ℹ If 'bootstrap' is not recognized, run 'exec bash' and then 'bootstrap'."

