#!/usr/bin/env bash
# ~/.bash/bootstrap.sh
# PKGBUILD-aware environment bootstrap for Arch Linux

set -euo pipefail

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

ensure_yay() {
    if ! command -v yay &>/dev/null; then
        echo "Installing yay (AUR helper)..."
        tmpdir=$(mktemp -d)
        git clone https://aur.archlinux.org/yay.git "$tmpdir"
        pushd "$tmpdir" >/dev/null
        makepkg -si --noconfirm
        popd >/dev/null
        rm -rf "$tmpdir"
    fi
}

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

bootstrap() {
    echo "🔹 Running PKGBUILD-aware bootstrap..."

    ensure_yay

    local folder="${1:-$HOME/Projects/dotfiles/pkgbuilds}"
    if [[ ! -d "$folder" ]]; then
        echo "❌ Folder '$folder' does not exist."
        return 1
    fi

    for pkgbuild in "$folder"/PKGBUILD "$folder"/*/PKGBUILD; do
        [[ -f "$pkgbuild" ]] || continue
        echo "Processing $pkgbuild..."
        parse_pkgbuild_deps "$pkgbuild"
    done

    echo "✅ PKGBUILD bootstrap complete!"
}

# ----------------------------------------
# 5️⃣ Export system packages as PKGBUILD
# ----------------------------------------

export_pkgbuilds() {
    local export_dir="${1:-$HOME/Projects/dotfiles/pkgbuilds/generated}"
    mkdir -p "$export_dir"
    local outfile="$export_dir/PKGBUILD"

    echo "🔹 Scanning installed packages..."
    local repo_pkgs aur_pkgs
    repo_pkgs=$(pacman -Qqe | sort)
    aur_pkgs=$(yay -Qm | awk '{print $1}' | sort)

    echo "🔹 Generating $outfile"

    cat > "$outfile" <<EOF
# Auto-generated PKGBUILD (snapshot of installed environment)
pkgname=dotfiles-meta
pkgver=1.0
pkgrel=1
arch=('any')
license=('custom')
depends=(
$(echo "$repo_pkgs" | sed 's/^/  /')
)
makedepends=(
$(echo "$aur_pkgs" | sed 's/^/  /')
)
EOF

    echo "✅ Export complete! Generated $outfile"
}

# ----------------------------------------
# 6️⃣ Versioned PKGBUILD Snapshots + Git Sync
# ----------------------------------------

timestamp() {
    date +"%Y-%m-%d_%H-%M-%S"
}

export_pkgbuilds_versioned() {
    local base_dir="${1:-$HOME/Projects/dotfiles/pkgbuilds/generated}"
    mkdir -p "$base_dir"

    local snap_file="$base_dir/PKGBUILD-$(timestamp)"
    local latest_file="$base_dir/PKGBUILD"

    echo "📦 Generating new versioned PKGBUILD snapshot..."
    export_pkgbuilds "$base_dir"

    mv "$latest_file" "$snap_file"
    ln -sf "$(basename "$snap_file")" "$latest_file"

    echo "✅ Created $snap_file and updated symlink → PKGBUILD"
}

dotfiles_push() {
    local repo_dir="${1:-$HOME/Projects/dotfiles}"
    pushd "$repo_dir" >/dev/null || return

    echo "📤 Committing dotfile and package updates..."
    export_pkgbuilds_versioned

    git add -A
    git commit -m "dotfiles update: $(timestamp)" || echo "🟡 Nothing new to commit."
    git push || echo "⚠️ Git push failed (check remote or credentials)."

    popd >/dev/null
    echo "✅ Dotfiles pushed successfully."
}

dotfiles_pull() {
    local repo_dir="${1:-$HOME/Projects/dotfiles}"
    pushd "$repo_dir" >/dev/null || return

    echo "📥 Pulling latest dotfile updates..."
    git pull --rebase
    echo "✅ Updated local repo."

    popd >/dev/null
}

