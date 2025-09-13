#!/usr/bin/env bash
# Restore symlinks for dotfiles repo
# Usage: ./restore_dotfiles.sh

set -e

REPO_DIR="$HOME/Projects/dotfiles"

# Ensure repo exists
if [ ! -d "$REPO_DIR/.git" ]; then
  echo "❌ Repo not found at $REPO_DIR"
  echo "Clone it first:"
  echo "  git clone git@github.com:USERNAME/dotfiles.git $REPO_DIR"
  exit 1
fi

echo "🔗 Creating symlinks from $REPO_DIR"

# Helper: create symlink safely
link() {
  local target=$1
  local linkname=$2

  # Remove if symlink already exists
  if [ -L "$linkname" ]; then
    rm "$linkname"
  # Backup if a regular file or dir already exists
  elif [ -e "$linkname" ]; then
    mv "$linkname" "$linkname.bak.$(date +%s)"
    echo "📦 Backed up $linkname"
  fi

  ln -s "$target" "$linkname"
  echo "✅ Linked $linkname → $target"
}

# Bash/Zsh configs
[ -f "$REPO_DIR/.bashrc" ] && link "$REPO_DIR/.bashrc" "$HOME/.bashrc"
[ -f "$REPO_DIR/.profile" ] && link "$REPO_DIR/.profile" "$HOME/.profile"
[ -f "$REPO_DIR/.zshrc" ] && link "$REPO_DIR/.zshrc" "$HOME/.zshrc"

# Neovim
[ -d "$REPO_DIR/.config/nvim" ] && link "$REPO_DIR/.config/nvim" "$HOME/.config/nvim"

# Other configs
[ -d "$REPO_DIR/.config/tmux" ] && link "$REPO_DIR/.config/tmux" "$HOME/.config/tmux"
[ -d "$REPO_DIR/.config/ranger" ] && link "$REPO_DIR/.config/ranger" "$HOME/.config/ranger"

# Local bin
[ -d "$REPO_DIR/.local/bin" ] && link "$REPO_DIR/.local/bin" "$HOME/.local/bin"

echo "🎉 Restore complete!"
