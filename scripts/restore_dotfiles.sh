#!/usr/bin/env bash
# ~/Projects/dotfiles/scripts/restore_dotfiles.sh
# Restore symlinks and environment setup from dotfiles repo safely

set -euo pipefail

REPO_DIR="$HOME/Projects/dotfiles"

# --- 1. Check repo ---
if [ ! -d "$REPO_DIR/.git" ]; then
  echo "❌ Repo not found at $REPO_DIR"
  echo "Clone it first:"
  echo "  git clone git@github.com:USERNAME/dotfiles.git $REPO_DIR"
  exit 1
fi

mkdir -p "$HOME/.config"
mkdir -p "$HOME/.local/bin"

echo "🔗 Restoring symlinks from $REPO_DIR ..."
echo

# --- 2. Helper function: create symlink safely ---
link() {
  local target=$1
  local linkname=$2

  if [ -L "$linkname" ]; then
    rm -f "$linkname"
  elif [ -e "$linkname" ]; then
    mv "$linkname" "$linkname.bak.$(date +%s)"
    echo "📦 Backed up $linkname"
  fi

  ln -s "$target" "$linkname"
  echo "✅ Linked $linkname → $target"
}

# --- 3. Core dotfiles ---
for f in .bashrc .bash_profile .zshrc .profile; do
  [ -f "$REPO_DIR/$f" ] && link "$REPO_DIR/$f" "$HOME/$f"
done

# --- 4. Bash modules ---
if [ -d "$REPO_DIR/bash" ]; then
  echo "🔹 Linking bash modules..."
  for mod in "$REPO_DIR/bash"/*.sh; do
    [ -f "$mod" ] && echo "  ↳ $(basename "$mod")"
  done
else
  echo "⚠️  No bash module folder found"
fi

# --- 5. Config directories (Neovim, tmux, ranger, etc.) ---
for cfg in "$REPO_DIR/.config"/*; do
  [ -d "$cfg" ] || continue
  name=$(basename "$cfg")
  link "$cfg" "$HOME/.config/$name"
done

# --- 6. Local bin scripts ---
if [ -d "$REPO_DIR/.local/bin" ]; then
  echo "🔹 Linking executables in .local/bin ..."
  for script in "$REPO_DIR/.local/bin"/*; do
    [ -f "$script" ] && link "$script" "$HOME/.local/bin/$(basename "$script")"
  done
fi

# --- 7. Optional cleanup ---
echo "🧹 Cleaning broken symlinks (max depth 3)..."
find -L "$HOME" -maxdepth 3 -type l -exec rm -f {} \; 2>/dev/null || true

# --- 8. Done ---
echo
echo "🎉 Restore complete!"
echo "You can now run:"
echo "  source ~/.bashrc"
echo "or open a new shell."

