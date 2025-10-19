#!/bin/bash
# generate_post_install_cheatsheet.sh
# Generates a post-install workflow cheat sheet

set -euo pipefail

BACKUP_DIR="$HOME/backupdrive"
POST_INSTALL_FILE="$BACKUP_DIR/post_install_cheatsheet.txt"

mkdir -p "$BACKUP_DIR"

{
    echo "============================="
    echo "POST-INSTALL CHEAT SHEET"
    echo "============================="
    echo
    echo "Generated on: $(date)"
    echo
    echo "1) Mount backup drive and check contents:"
    echo "   # mkdir -p /mnt/backup"
    echo "   # mount /dev/sdd1 /mnt/backup   # adjust device if different"
    echo
    echo "2) Restore home directories or selected files:"
    echo "   # tar -xzf /mnt/backup/backup.tar.gz -C /home"
    echo "   STOP: Choose files/folders selectively if needed"
    echo
    echo "3) Reference /etc configuration files (do NOT overwrite blindly):"
    echo "   # vimdiff /mnt/backup/etc/fstab /etc/fstab"
    echo "   # vim /mnt/backup/etc/hostname"
    echo "   # Compare other important files in /etc as needed"
    echo
    echo "4) Restore dotfiles/repos:"
    echo "   # cd ~/Projects"
    echo "   # git clone git@github.com:jtowersgh/dotfiles.git"
    echo "   # cd dotfiles && ./restore_dotfiles.sh  # if you have a script"
    echo
    echo "5) Restore package lists (Pacman & AUR):"
    echo "   # sudo pacman -S --needed - < pacman_packages.txt"
    echo "   # Use AUR helper for aur_packages.txt if needed"
    echo
    echo "6) Restore SSH keys and config:"
    echo "   # mkdir -p ~/.ssh"
    echo "   # cp /mnt/backup/ssh_keys/* ~/.ssh/"
    echo "   # chmod 700 ~/.ssh"
    echo "   # chmod 600 ~/.ssh/id_rsa"
    echo "   # ssh-add ~/.ssh/id_rsa"
    echo
    echo "7) Restore GPG keys if needed:"
    echo "   # gpg --import /mnt/backup/gpg_backup.asc"
    echo
    echo "8) Restore systemctl services:"
    echo "   # cp /mnt/backup/systemd_services/*.service /etc/systemd/system/"
    echo "   # systemctl daemon-reload"
    echo "   # systemctl enable <service>"
    echo "   # systemctl start <service>"
    echo
    echo "9) Reapply any custom environment variables, paths, aliases, etc."
    echo "   # vim ~/.bashrc or ~/.zshrc"
    echo
    echo "10) Verify backups and configurations are working:"
    echo "   # lsblk, df -h, cat /etc/fstab"
    echo "   # test key-based SSH logins, run systemctl status"
    echo
    echo "11) Install additional packages selectively from your saved package list."
    echo
    echo "12) Optional: compress or archive the restored backup for future reference."
} > "$POST_INSTALL_FILE"

echo "Post-install cheat sheet created: $POST_INSTALL_FILE"

