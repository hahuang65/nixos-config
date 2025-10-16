#!/usr/bin/env nix-shell
#!nix-shell -i bash -p jq curl git gh
set -euo pipefail

REPO_FULL="$1"
PACKAGES_DIR="home/neovim/github-packages"

# Validate repo format
if [[ ! "$REPO_FULL" =~ ^[^/]+/[^/]+$ ]]; then
  echo "Error: Repository must be in format 'owner/repo'"
  echo "Example: just neovim-remove-github nvim-treesitter/nvim-treesitter"
  exit 1
fi

# Generate filename from repo owner/name (replace '/' with '-')
filename="${REPO_FULL//\//-}.nix"
filepath="$PACKAGES_DIR/$filename"

# Check if package exists
if [[ ! -f "$filepath" ]]; then
  echo "❌ Package $REPO_FULL not found at $filepath"
  echo "Available packages:"
  ls -1 "$PACKAGES_DIR"/*.nix 2>/dev/null | xargs -I {} basename {} .nix | sed 's/-/\//' || echo "  No packages found"
  exit 1
fi

# Remove the package file
echo "🗑️  Removing package: $REPO_FULL"
echo "📄 File: $filepath"

rm "$filepath"

echo "✅ Successfully removed package $REPO_FULL"