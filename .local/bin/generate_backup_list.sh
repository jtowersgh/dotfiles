#!/bin/bash
# generate_backup_list.sh
# Generates a backup list for selected XDG-style directories, dotfiles, SSH keys, password store, and package lists

set -euo pipefail

# -------- CONFIG --------
BACKUP_LIST="$HOME/backup_list.txt"
EDITOR_CMD="nvim"   # Change to your preferred editor

# Whitelist
INCLUDE=(
  # Personal media
  "$HOME/Documents"
  "$HOME/Pictures"
  "$HOME/Music"
  "$HOME/Videos"

  # XDG-style config & app data
  "$HOME/.config"
  "$HOME/.local/share"
  "$HOME/.local/bin"

  # Projects
  "$HOME/Projects"

  # scripts
  "$HOME/scripts"

  # Dotfiles
  "$HOME/.gitconfig"
  "$HOME/.bashrc"
  "$HOME/.bash_profile"
  "$HOME/.bash_logout"
  "$HOME/.profile"
  "$HOME/.inputrc"
  "$HOME/.bash_aliases"
  "$HOME/.bash_functions"
  "$HOME/.zshrc"
  "$HOME/.tmux.conf"

  # Keys / security
  "$HOME/.ssh"
  "$HOME/.gnupg"

  # Password store
  "$HOME/.password-store"

  # etc directory
  "/etc"
)

# -------- FUNCTIONS --------
generate_backup_list() {
  echo "Scanning selected directories..."
  > "$BACKUP_LIST"

  for dir in "${INCLUDE[@]}"; do
    if [[ -e "$dir" ]]; then
      while IFS= read -r -d $'\0' file; do
        echo "$file" >> "$BACKUP_LIST"
      done < <(find "$dir" -mindepth 1 -print0)
    fi
  done

  echo "Backup list generated at $BACKUP_LIST"
}

export_package_lists() {
  BACKUP_METADATA="$HOME/.local/share/backup_metadata"
  mkdir -p "$BACKUP_METADATA"

  PACMAN_LIST="$BACKUP_METADATA/pacman_installed.txt"
  AUR_LIST="$BACKUP_METADATA/aur_installed.txt"

  pacman -Qqe > "$PACMAN_LIST" || echo "Warning: could not export pacman list"
  pacman -Qqm > "$AUR_LIST" || echo "Warning: could not export AUR list"

  echo "Package lists saved:"
  echo " $PACMAN_LIST"
  echo " $AUR_LIST"

  echo "$PACMAN_LIST" >> "$BACKUP_LIST"
  echo "$AUR_LIST" >> "$BACKUP_LIST"
}

review_backup_list() {
  echo "Opening backup list for review..."
  $EDITOR_CMD "$BACKUP_LIST"
}

# -------- MAIN --------
generate_backup_list
export_package_lists
review_backup_list

