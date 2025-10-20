# Dotfiles Setup

This repository contains my personal dotfiles, including Neovim config, bash modules, and helper scripts.  

---

## Quick Install

Run the all-in-one installer:

```bash
cd ~/Projects/dotfiles
./install.sh

What it does

    Restores dotfiles symlinks
    Links .bashrc, .bash_profile, Neovim config, and any other managed files.

    Ensures basic directories exist
    Creates ~/.config, ~/Projects/dotfiles/bash, and ~/Projects/dotfiles/pkgbuilds.

    Installs essential system packages
    Installs git, neovim, and base-devel via pacman.

    Sources new .bashrc
    Ensures aliases and functions (like bootstrap) are available in the current shell.

    Installs packer.nvim if missing
    Automatically clones Packer into Neovim’s site/pack/packer/start/ directory.

    Installs all Neovim plugins
    Runs :PackerInstall headless to populate plugins before Lua configs run.

    Bootstraps PKGBUILD dependencies
    Installs AUR and repo packages defined in pkgbuilds/.

    Updates plugins
    Runs :PackerSync headless to ensure plugins are up-to-date.

After Installation

    If bootstrap isn’t recognized, run:

exec bash
bootstrap

    Open Neovim:

nvim

All plugins, including LSP and color schemes, should now load correctly.
Notes

    First-time Neovim runs:
    The first nvim --headless +PackerInstall +qa ensures all plugins exist so your init.lua can require() them without errors.

    Git name/email constants:
    You can configure your Git user details inside bootstrap.sh if you want dotfiles_push to commit automatically.

    Troubleshooting:
    If any plugin fails to load, open Neovim manually and run :PackerInstall or :PackerSync to debug.
