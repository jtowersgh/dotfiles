#!/bin/bash
# clean_build_backup.sh
# Interactive backup for a clean system build
# Modular: generates list, allows edits, then backs up
# Includes pacman and AUR package lists

set -euo pipefail

# -------- CONFIG --------
HOME_DIR="$HOME"
EXCLUDE=(
    "$HOME_DIR/.cache"
    "$HOME_DIR/.local/share/Trash"
    "$HOME_DIR/Downloads"
)
BACKUP_LIST="$HOME/backup_list.txt"
PACMAN_LIST="$HOME/pkglist_pacman.txt"
AUR_LIST="$HOME/pkglist_aur.txt"

# -------- FUNCTIONS --------
in_exclude() {
    local path="$1"
    for e in "${EXCLUDE[@]}"; do
        [[ "$path" == "$e"* ]] && return 0
    done
    return 1
}

generate_backup_list() {
    echo "Scanning $HOME_DIR for backup candidates..."
    > "$BACKUP_LIST"
    while IFS= read -r -d $'\0' file; do
        if ! in_exclude "$file"; then
            echo "$file" >> "$BACKUP_LIST"
        fi
    done < <(find "$HOME_DIR" -mindepth 1 -print0)
    echo "Backup list generated at $BACKUP_LIST"
}

generate_package_lists() {
    echo "Generating package lists..."
    # Pacman packages
    pacman -Qq > "$PACMAN_LIST" 2>/dev/null || echo "Warning: Could not generate pacman package list"
    # AUR packages (if yay is installed)
    if command -v yay &>/dev/null; then
        yay -Qqe > "$AUR_LIST" 2>/dev/null || echo "Warning: Could not generate AUR package list"
    else
        echo "Warning: yay not installed; skipping AUR package list"
        > "$AUR_LIST"
    fi
    echo "Package lists saved:"
    [[ -s "$PACMAN_LIST" ]] && echo "  $PACMAN_LIST"
    [[ -s "$AUR_LIST" ]] && echo "  $AUR_LIST"
}

review_backup_list() {
    echo "Opening backup list for review..."
    ${EDITOR:-nano} "$BACKUP_LIST"
}

perform_backup() {
    local dest="$1"
    if [[ -z "$dest" ]]; then
        echo "Error: No backup destination provided."
        exit 1
    fi

    mkdir -p "$dest"
    echo "Starting backup to $dest..."
    local failed_files="$dest/failed_permissions.txt"
    > "$failed_files"

    # Backup files from backup list
    while IFS= read -r file; do
        if [[ -e "$file" ]]; then
            tar --ignore-failed-read -czf "$dest/backup.tar.gz" -C / "$(realpath --relative-to=/ "$file")" || \
            echo "$file" >> "$failed_files"
        fi
    done < "$BACKUP_LIST"

    # Add package lists to the archive
    tar -C "$HOME" -rzf "$dest/backup.tar.gz" pkglist_pacman.txt pkglist_aur.txt 2>/dev/null || true

    if [[ -s "$failed_files" ]]; then
        echo "Some files could not be backed up due to permissions:"
        cat "$failed_files"
    fi

    echo "Backup complete."
    echo "Archive location: $dest/backup.tar.gz"
    [[ -s "$failed_files" ]] && echo "List of skipped files: $failed_files"
}

# -------- MAIN --------
generate_backup_list
generate_package_lists
review_backup_list

# Tab-completion enabled prompt for destination
read -e -p "Enter backup destination (full path): " BACKUP_DEST

perform_backup "$BACKUP_DEST"
