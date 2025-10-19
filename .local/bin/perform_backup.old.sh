#!/bin/bash
set -euo pipefail

BACKUP_LIST="$HOME/backup_list.txt"

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

    tar --ignore-failed-read -czf "$dest/backup.tar.gz" -T "$BACKUP_LIST" 2>>"$failed_files"

    # Save a copy of the current fstab alongside the backup
    cp /etc/fstab "$dest/fstab.old"

    if [[ -s "$failed_files" ]]; then
        echo "Some files could not be backed up due to permissions:"
        cat "$failed_files"
    fi

    echo "Backup complete."
    echo "Archive location: $dest/backup.tar.gz"
    echo "fstab copy: $dest/fstab.old"
    [[ -s "$failed_files" ]] && echo "List of skipped files: $failed_files"
}

# -------- MAIN --------
if [[ ! -f "$BACKUP_LIST" ]]; then
    echo "Error: Backup list not found at $BACKUP_LIST"
    echo "Run generate_backup_list.sh first."
    exit 1
fi

# Use first argument as backup destination if provided; otherwise prompt with tab-completion
if [[ $# -ge 1 ]]; then
    BACKUP_DEST="$1"
else
    # Enable tab completion for directories
    read -e -p "Enter backup destination (full path): " -i "$HOME/" BACKUP_DEST
fi

perform_backup "$BACKUP_DEST"

