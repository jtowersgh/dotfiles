#!/usr/bin/env bash
# ~/.bash/bootstrap.sh
# PKGBUILD-aware environment bootstrap for Arch Linux + Neovim plugin setup

set -euo pipefail

# -----------------------------
# 0. Ensure yay (AUR helper) installed
# -----------------------------
ensure_yay() {
    if ! command -v yay &>/dev/null; then
        echo "📦 Installing yay (AUR helper)..."
        tmpdir=$(mktemp -d)
        git clone https://aur.archlinux.org/yay.git "$tmpdir"
        pushd "$tmpdir" >/dev/null
        makepkg -si --noconfirm
        popd >/dev/null
        rm -rf "$tmpdir"
    fi
}

# -----------------------------
# 1. Install repo / AUR packages
# -----------------------------
install_repo_pkg() {
    local pkg="$1"
    if ! pacman -Qi "$pkg" &>/dev/null; then
        echo "Installing $pkg from official repos..."
        sudo pacman -S --noconfirm "$pkg"
    fi
}

install_aur_pkg() {
    local pkg="$1"
    if ! pacman -Qi "$pkg" &>/dev/null && ! yay -Qi "$pkg" &>/dev/null; then
        echo "Installing $pkg from AUR..."
        yay -S --noconfirm "$pkg"
    fi
}

# -----------------------------
# 2. Parse PKGBUILD dependencies
# -----------------------------
parse_pkgbuild_deps() {
    local pkgbuild="$1"
    declare -A deps
    local dep_types=("depends" "makedepends" "checkdepends" "optdepends")

    for type in "${dep_types[@]}"; do
        pkgs=$(grep -E "^${type}=" "$pkgbuild" \
            | sed -E "s/.*=\((.*)\)/\1/" \
            | tr -d "'" \
            | tr ' ' '\n' \
            | cut -d: -f1 \
            | sort -u \
            | grep -v '^$' || true)
        deps["$type"]="$pkgs"
    done

    for type in "${dep_types[@]}"; do
        [[ -z "${deps[$type]}" ]] && continue
        echo "=== $type ==="
        for pkg in ${deps[$type]}; do
            if pacman -Si "$pkg" &>/dev/null; then
                install_repo_pkg "$pkg"
            else
                install_aur_pkg "$pkg"
            fi
        done
    done
}

# -----------------------------
# 3. Bootstrap environment
# -----------------------------
bootstrap() {
    echo "🔹 Running PKGBUILD-aware bootstrap..."
    ensure_yay

    local folder="${1:-$HOME/Projects/dotfiles/pkgbuilds}"
    if [[ ! -d "$folder" ]]; then
        echo "ℹ  Folder '$folder' does not exist — skipping PKGBUILD installs."
        return 0
    fi

    for pkgbuild in "$folder"/PKGBUILD "$folder"/*/PKGBUILD; do
        [[ -f "$pkgbuild" ]] || continue
        echo "Processing $pkgbuild..."
        parse_pkgbuild_deps "$pkgbuild"
    done

    # -----------------------------
    # 3a. Neovim Plugin Setup
    # -----------------------------
    if command -v nvim &>/dev/null; then
        NVIM_PACK_HOME="$HOME/.local/share/nvim/site/pack/packer/start"
        mkdir -p "$NVIM_PACK_HOME"
        if [[ ! -d "$NVIM_PACK_HOME/packer.nvim" ]]; then
            echo "📦 Installing packer.nvim..."
            git clone --depth 1 https://github.com/wbthomason/packer.nvim "$NVIM_PACK_HOME/packer.nvim"
        fi
        echo "🔹 Installing Neovim plugins..."
        nvim --headless +PackerSync +qa || echo "⚠ Neovim plugin install failed. Run 'nvim' manually to complete."
    fi

    echo "✅ PKGBUILD bootstrap complete!"
}

# -----------------------------
# 4. Export versioned PKGBUILD snapshot
# -----------------------------
timestamp() { date +"%Y-%m-%d_%H-%M-%S"; }

export_pkgbuilds_versioned() {
    local base_dir="${1:-$HOME/Projects/dotfiles/pkgbuilds/generated}"
    mkdir -p "$base_dir"
    local snap_file="$base_dir/PKGBUILD-$(timestamp)"
    local latest_file="$base_dir/PKGBUILD"

    echo "📦 Exporting installed packages to $snap_file..."
    pacman -Qqe | sort > "$base_dir/repo_pkgs.txt"
    yay -Qm | awk '{print $1}' | sort > "$base_dir/aur_pkgs.txt"

    cat > "$snap_file" <<EOF
# Auto-generated PKGBUILD (snapshot)
pkgname=dotfiles-meta
pkgver=1.0
pkgrel=1
arch=('any')
license=('custom')
depends=(
$(cat "$base_dir/repo_pkgs.txt" | sed 's/^/  /')
)
makedepends=(
$(cat "$base_dir/aur_pkgs.txt" | sed 's/^/  /')
)
EOF

    ln -sf "$(basename "$snap_file")" "$latest_file"
    echo "✅ Versioned PKGBUILD snapshot created."
}

# -----------------------------
# 5. Git helpers
# -----------------------------
dotfiles_push() {
    local repo_dir="${1:-$HOME/Projects/dotfiles}"
    pushd "$repo_dir" >/dev/null || return
    echo "📤 Committing and pushing dotfiles..."
    export_pkgbuilds_versioned
    git add -A
    git commit -m "dotfiles update: $(timestamp)" || echo "🟡 Nothing new to commit."
    git push || echo "⚠ Git push failed."
    popd >/dev/null
}

dotfiles_pull() {
    local repo_dir="${1:-$HOME/Projects/dotfiles}"
    pushd "$repo_dir" >/dev/null || return
    echo "📥 Pulling latest dotfile updates..."
    git pull --rebase
    popd >/dev/null
}

# -----------------------------
# 6. Optional helper: install a specific package list
# -----------------------------
install_dependencies() {
    local packages=("$@")
    for pkg in "${packages[@]}"; do
        if pacman -Si "$pkg" &>/dev/null; then
            install_repo_pkg "$pkg"
        else
            install_aur_pkg "$pkg"
        fi
    done
}

# -----------------------------
# 7. Ensure Packer helper: Ensure packer.nvim is installed for Neovim ---
# -----------------------------
# --- Ensure packer.nvim is installed for Neovim ---
ensure_packer() {
    local packer_path="$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim"
    if [ ! -d "$packer_path" ]; then
        echo "📦 Installing packer.nvim..."
        git clone --depth 1 https://github.com/wbthomason/packer.nvim "$packer_path"
    fi
}

# At the end of bootstrap()
bootstrap() {
    echo "🔹 Running PKGBUILD-aware bootstrap..."
    ensure_yay

    local folder="${1:-$HOME/Projects/dotfiles/pkgbuilds}"
    [[ ! -d "$folder" ]] && echo "ℹ Folder '$folder' does not exist — skipping PKGBUILD installs." && return

    for pkgbuild in "$folder"/PKGBUILD "$folder"/*/PKGBUILD; do
        [[ -f "$pkgbuild" ]] || continue
        parse_pkgbuild_deps "$pkgbuild"
    done

    # Ensure Neovim plugins are installed
    ensure_packer
    nvim --headless +PackerSync +qa

    echo "✅ PKGBUILD bootstrap complete!"
}

