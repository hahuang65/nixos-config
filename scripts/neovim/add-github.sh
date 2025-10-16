#!/usr/bin/env nix-shell
#!nix-shell -i bash -p jq curl git gh
set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common GitHub functions
source "$SCRIPT_DIR/../common/github.sh"

REPO_FULL="$1"
PACKAGES_DIR="home/neovim/github-packages"

# Validate repo format
if [[ ! "$REPO_FULL" =~ ^[^/]+/[^/]+$ ]]; then
  echo "Error: Repository must be in format 'owner/repo'"
  echo "Example: just add-neovim-github nvim-treesitter/nvim-treesitter"
  exit 1
fi

# Generate filename from repo owner/name (replace '/' with '-')
filename="${REPO_FULL//\//-}.nix"
filepath="$PACKAGES_DIR/$filename"

# Check if package already exists
if [[ -f "$filepath" ]]; then
  echo "📦 Package $REPO_FULL already exists at $filepath"
  exit 0
fi

echo "🔍 Fetching latest info for $REPO_FULL..."

# Set up authentication
setup_github_auth

# Get latest commit
get_latest_commit "$REPO_FULL" || exit 1

echo "📦 Latest commit: ${latest_rev:0:8} on branch '$default_branch'"

# Get the hash
echo "🔍 Calculating hash..."
calculate_hash "$REPO_FULL" "$latest_rev" || exit 1

echo "✅ Hash: ${hash:0:16}..."

# Generate the Nix package definition
package_content="{ fromGitHub }:
fromGitHub {
  repo = \"$REPO_FULL\";
  rev = \"$latest_rev\";
  hash = \"$hash\";
}"

# Create the package file
echo "$package_content" >"$filepath"

echo
echo "✅ Created new package file: $filepath"
echo "📝 Package definition:"
echo "$package_content"

