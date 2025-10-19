# Dotfiles Setup & Workflow

This repository manages personal dotfiles, scripts, and PKGBUILD-aware package installations for Arch Linux.

## Scripts Overview

### 1. `setup_system.sh`
- Installs essential system packages (`git`, `yay`, `ethtool`, etc.).
- Configures Git global identity (`user.name` / `user.email`).
- Run **once per system** before using the dotfiles repo.

### 2. `install.sh`
- Restores all dotfile symlinks from this repo to the home directory.
- Creates required directories (`.config`, `bash`, `pkgbuilds`).
- Sources `.bashrc` for immediate availability of aliases and functions.
- Run **once on a fresh system** or after restoring a backup.

### 3. `restore_dotfiles.sh`
- Safely recreates symlinks for:
  - `.bashrc`, `.profile`, `.zshrc`
  - `.config/nvim`, `.config/tmux`, `.config/ranger`
  - `.local/bin`
- Backs up existing files if necessary.
- Can be run **any time** you want to refresh dotfile symlinks.

### 4. `bootstrap.sh`
- Installs all packages from PKGBUILD definitions (official repo + AUR).
- Ensures `yay` is installed for AUR package management.
- Can export a snapshot of installed packages as versioned PKGBUILD.
- Run **after `install.sh`** to configure your system environment.

### 5. `update_dotfiles.sh` / `dotfiles_push`
- Commits and pushes changes to the remote repository.
- Versioned PKGBUILD snapshot is included.
- Run **after modifying dotfiles or scripts**.

## Recommended Workflow on a Fresh System

1. Run `setup_system.sh` to install core dependencies and configure Git.  
2. Run `install.sh` to restore dotfiles and directories.  
3. Run `bootstrap.sh` to install packages from PKGBUILD definitions.  
4. Use `dotfiles_push` to commit and push changes back to GitHub (optional).

> **Note:** `restore_dotfiles.sh` can be run independently at any time without affecting installed packages.

