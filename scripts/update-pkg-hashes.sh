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
        echo "❌ Error: File $nix_file not found!"
        return 1
    fi

    # URL to the tarball
    local tar_url="$repo_url/archive/$branch.tar.gz"
    
    echo "⬇️  Downloading source from: $tar_url"
    
    # Create temp file
    local tmp_file=$(mktemp)
    
    # Download with curl
    if curl -L -s -o "$tmp_file" "$tar_url"; then
        # Calculate SHA256 using nix-prefetch-url if available (preferred for SRI), otherwise sha256sum/shasum
        local hash=""
        
        if command -v nix-prefetch-url >/dev/null 2>&1; then
            echo "⚙️  Using nix-prefetch-url..."
            hash=$(nix-prefetch-url --unpack "$tar_url" 2>/dev/null)
        else 
            echo "⚙️  Using shasum (fallback)..."
            # Get sha256
            if command -v sha256sum >/dev/null 2>&1; then
                 raw_hash=$(sha256sum "$tmp_file" | cut -d' ' -f1)
            else
                 # Mac support
                 raw_hash=$(shasum -a 256 "$tmp_file" | cut -d' ' -f1)
            fi
            # Nix expects sha256: prefix usually or just the hash for recent nix, 
            # but let's assume standard hex is accepted if not SRI.
            # Ideally we'd convert to SRI but hex works often.
            hash="$raw_hash"
        fi

        echo "🔑 Calculated Hash: $hash"

        # Update the file
        # We look for "sha256 = ...;" line
        # Use a temporary file for sed to avoid portability issues
        local sed_tmp=$(mktemp)
        
        # Replace lib.fakeSha256 OR any existing string in quotes
        sed "s|sha256 = .*;|sha256 = \"$hash\";|" "$nix_file" > "$sed_tmp" && mv "$sed_tmp" "$nix_file"
        
        echo "✅ Updated $nix_file"
        rm -f "$tmp_file"
    else
        echo "❌ Failed to download source."
        rm -f "$tmp_file"
        return 1
    fi
}

# Define packages to update
# Format: update_hash "folder_name" "github_url" "branch"

update_hash "mewline" "https://github.com/meowrch/mewline" "main"
update_hash "hotkeyhub" "https://github.com/meowrch/HotkeyHub" "main"
update_hash "meowrch-settings" "https://github.com/meowrch/meowrch-settings" "main"
update_hash "meowrch-tools" "https://github.com/meowrch/meowrch-tools" "main"

echo "----------------------------------------------------------------"
echo "🎉 All package hashes updated!"
