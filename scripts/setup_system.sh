#!/usr/bin/env bash
# ~/Projects/dotfiles/setup_system.sh
# System-wide setup for a new Arch Linux machine
# Run before linking dotfiles

set -euo pipefail

# ----------------------------
# 1️⃣ Set Git global identity
# ----------------------------
# <<< INSERT YOUR NAME AND EMAIL HERE >>>
GIT_USER_NAME="jtowersgh"
GIT_USER_EMAIL="jtowersgcf@gmail.com"

# Only set if not already configured
git_name=$(git config --global user.name || echo "")
git_email=$(git config --global user.email || echo "")

if [[ -z "$git_name" || -z "$git_email" ]]; then
    echo "Setting Git identity..."
    git config --global user.name "$GIT_USER_NAME"
    git config --global user.email "$GIT_USER_EMAIL"
    echo "✅ Git identity set: $GIT_USER_NAME <$GIT_USER_EMAIL>"
else
    echo "✅ Git identity already configured: $git_name <$git_email>"
fi

# ----------------------------
# 2️⃣ Ensure Git is installed
# ----------------------------
if ! command -v git &>/dev/null; then
    echo "Git not found. Installing..."
    sudo pacman -S --noconfirm git
fi

# ----------------------------
# 3️⃣ Install essential packages
# ----------------------------
declare -a packages=("vim" "wget" "fzf" "base-devel" "openssh")

for pkg in "${packages[@]}"; do
    if ! pacman -Qi "$pkg" &>/dev/null; then
        echo "Installing $pkg..."
        sudo pacman -S --noconfirm "$pkg"
    fi
done

# ----------------------------
# 4️⃣ Enable SSH service
# ----------------------------
if ! systemctl is-enabled sshd &>/dev/null; then
    echo "Enabling SSH..."
    sudo systemctl enable --now sshd
fi

echo "✅ System setup complete!"

