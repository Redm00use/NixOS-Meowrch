#!/usr/bin/env bash
set -e

# Directory containing this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PKGS_DIR="$PROJECT_ROOT/pkgs"

# Function to update hash for a package
update_hash() {
    local pkg_name=$1
    local repo_url=$2
    local branch=$3
    local nix_file="$PKGS_DIR/$pkg_name/default.nix"

    echo "----------------------------------------------------------------"
    echo "📦 Processing $pkg_name..."

    if [ ! -f "$nix_file" ]; then
        # Check in packages/ directory too
        nix_file="$PROJECT_ROOT/packages/$pkg_name.nix"
        if [ ! -f "$nix_file" ]; then
            echo "❌ Error: File $pkg_name.nix not found in pkgs/ or packages/!"
            return 1
        fi
    fi

    # URL to the tarball
    local tar_url="$repo_url/archive/$branch.tar.gz"
    echo "⬇️  Downloading source from: $tar_url"
    
    local hash=$(nix-prefetch-url --unpack "$tar_url" 2>/dev/null)
    if [ -n "$hash" ]; then
        sri_hash="sha256-$(nix-hash --to-base64 --type sha256 $hash)"
        echo "🔑 Calculated SRI Hash: $sri_hash"
        
        if grep -q "hash =" "$nix_file"; then
            sed -i "s|hash = .*;|hash = \"$sri_hash\";|" "$nix_file"
        elif grep -q "sha256 =" "$nix_file"; then
            # Special handling for multi-src files like meowrch-themes.nix
            # For now, we update the first one found or the one matching repo
            sed -i "s|sha256 = .*;|sha256 = \"$sri_hash\";|" "$nix_file"
        fi
        echo "✅ Updated $nix_file"
    else
        echo "❌ Failed to fetch hash."
    fi
}

# Standard Packages
update_hash "mewline" "https://github.com/meowrch/mewline" "v1.4.1"
update_hash "fabric" "https://github.com/Fabric-Development/fabric" "main"
update_hash "fabric-cli" "https://github.com/Fabric-Development/fabric-cli" "main"
update_hash "hotkeyhub" "https://github.com/meowrch/HotkeyHub" "v0.3"
update_hash "meowrch-settings" "https://github.com/meowrch/meowrch-settings" "v3.1.3"
update_hash "meowrch-tools" "https://github.com/meowrch/meowrch-tools" "v3.1.1"
update_hash "pawlette" "https://github.com/Meowrch/pawlette" "main"

# Special: Update Original Wallpapers in meowrch-themes.nix
echo "----------------------------------------------------------------"
echo "🖼️  Updating Original Meowrch Wallpapers..."
THEME_FILE="$PROJECT_ROOT/packages/meowrch-themes.nix"
WALL_HASH=$(nix-prefetch-url --unpack "https://github.com/meowrch/meowrch/archive/main.tar.gz" 2>/dev/null)
if [ -n "$WALL_HASH" ]; then
    SRI_WALL_HASH="sha256-$(nix-hash --to-base64 --type sha256 $WALL_HASH)"
    # We use a very specific sed to only update the meowrch-src placeholder
    sed -i "s|sha256 = \"sha256-1C0htvLBBO5YSWgWq/3SdCZZ4+mExRjlFYfOtRAI74k=\";|sha256 = \"$SRI_WALL_HASH\";|" "$THEME_FILE"
    echo "✅ Updated meowrch-src hash in meowrch-themes.nix"
else
    echo "❌ Failed to fetch wallpaper hash."
fi

echo "----------------------------------------------------------------"
echo "🎉 All package hashes updated!"
