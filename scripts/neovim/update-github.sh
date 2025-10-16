#!/usr/bin/env nix-shell
#!nix-shell -i bash -p jq curl git gh
set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common GitHub functions
source "$SCRIPT_DIR/../common/github.sh"

PACKAGES_DIR="home/neovim/github-packages"

# Set up authentication
setup_github_auth

updates_made=0
nix_files=($(find "$PACKAGES_DIR" -name "*.nix" -type f))

for nix_file in "${nix_files[@]}"; do
  basename_file=$(basename "$nix_file")

  # Extract package info from the file
  package_info=$(awk '
    /repo = "([^"]+)";/ {
      match($0, /repo = "([^"]+)";/, arr)
      repo_full = arr[1]
    }
    /rev = "([^"]+)";/ {
      match($0, /rev = "([^"]+)";/, arr)
      rev = arr[1]
    }
    /hash = "([^"]+)";/ {
      match($0, /hash = "([^"]+)";/, arr)
      hash = arr[1]
    }
    END {
      if (repo_full && rev && hash) {
        print repo_full ":" rev ":" hash
      }
    }
  ' "$nix_file")

  if [[ -z "$package_info" ]]; then
    echo "⚠️  Could not parse $basename_file, skipping..."
    continue
  fi

  IFS=: read -r repo_full current_rev current_hash <<<"$package_info"

  echo
  echo "Checking $basename_file ($repo_full)..."
  echo "  Current: ${current_rev:0:8}"

  # First get the default branch, then get its latest commit
  default_branch=$(curl -s -H "Accept: application/vnd.github.v3+json" \
    "${AUTH_ARGS[@]}" \
    "https://api.github.com/repos/$repo_full" |
    jq -r '.default_branch // empty' 2>/dev/null)

  if [[ -n "$default_branch" ]]; then
    latest_rev=$(curl -s -H "Accept: application/vnd.github.v3+json" \
      "${AUTH_ARGS[@]}" \
      "https://api.github.com/repos/$repo_full/commits/$default_branch" |
      jq -r '.sha // empty' 2>/dev/null)
    if [[ -z "$latest_rev" ]]; then
      echo "  ⚠️  Could not get latest commit from default branch '$default_branch'"
    fi
  else
    echo "  ⚠️  Could not determine default branch, trying main/master..."
    # Fallback to main/master
    latest_rev=$(curl -s -H "Accept: application/vnd.github.v3+json" \
      "${AUTH_ARGS[@]}" \
      "https://api.github.com/repos/$repo_full/commits/main" |
      jq -r '.sha // empty' 2>/dev/null ||
      curl -s -H "Accept: application/vnd.github.v3+json" \
        "${AUTH_ARGS[@]}" \
        "https://api.github.com/repos/$repo_full/commits/master" |
      jq -r '.sha // empty' 2>/dev/null || echo "")
  fi

  if [[ -z "$latest_rev" ]]; then
    echo "  ❌ Could not fetch latest commit"
    continue
  fi

  if [[ "$latest_rev" == "$current_rev" ]]; then
    echo "  ✅ Already up to date"
    continue
  fi

  echo "  📦 New version available: ${latest_rev:0:8}"

  # Get new hash using common function
  echo "  🔍 Fetching hash for $repo_full@${latest_rev:0:8}..."
  calculate_hash "$repo_full" "$latest_rev" || {
    echo "  ❌ Could not fetch hash, skipping this package"
    continue
  }
  new_hash="$hash"
  echo "  ✅ Got hash: ${new_hash:0:16}..."

  # Update the individual file
  if sed -i.bak \
    -e "s/rev = \"[^\"]*\";/rev = \"$latest_rev\";/" \
    -e "s/hash = \"[^\"]*\";/hash = \"$new_hash\";/" \
    "$nix_file" 2>/dev/null && ! cmp -s "$nix_file" "$nix_file.bak"; then
    echo "  ✅ Updated $basename_file to ${latest_rev:0:8}"
    updates_made=$((updates_made + 1))
    rm -f "$nix_file.bak"
  else
    echo "  ❌ Failed to update $basename_file"
    [[ -f "$nix_file.bak" ]] && mv "$nix_file.bak" "$nix_file"
  fi

done

echo
echo "🎉 Updated $updates_made packages"

if [[ $updates_made -gt 0 ]]; then
  echo
  echo "Run 'just build' or 'home-manager switch' to apply the updates"
fi
