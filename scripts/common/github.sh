#!/bin/bash

# Common GitHub functions for Neovim package management

setup_github_auth() {
  GITHUB_TOKEN=""
  if command -v gh >/dev/null && gh auth status >/dev/null 2>&1; then
    GITHUB_TOKEN=$(gh auth token 2>/dev/null || echo "")
    if [[ -n "$GITHUB_TOKEN" ]]; then
      echo "🔑 Using GitHub CLI authentication"
    fi
  elif git config --global credential.helper >/dev/null 2>&1; then
    GITHUB_TOKEN=$(printf "protocol=https\nhost=github.com\n" | git credential fill 2>/dev/null | grep "^password=" | cut -d'=' -f2 || echo "")
    if [[ -n "$GITHUB_TOKEN" ]]; then
      echo "🔑 Using git credential helper authentication"
    fi
  fi

  if [[ -n "$GITHUB_TOKEN" ]]; then
    AUTH_ARGS=("-H" "Authorization: token $GITHUB_TOKEN")
  else
    echo "⚠️  No GitHub authentication found - using anonymous access"
    AUTH_ARGS=()
  fi
}

get_latest_commit() {
  local repo_full="$1"
  repo_info=$(curl -s -H "Accept: application/vnd.github.v3+json" "${AUTH_ARGS[@]}" "https://api.github.com/repos/$repo_full" 2>/dev/null)

  if ! echo "$repo_info" | jq empty 2>/dev/null; then
    echo "❌ Repository not found or API error"
    return 1
  fi

  default_branch=$(echo "$repo_info" | jq -r '.default_branch // "main"')
  latest_rev=$(curl -s -H "Accept: application/vnd.github.v3+json" "${AUTH_ARGS[@]}" "https://api.github.com/repos/$repo_full/commits/$default_branch" | jq -r '.sha // empty' 2>/dev/null)

  if [[ -z "$latest_rev" ]]; then
    echo "❌ Could not fetch latest commit"
    return 1
  fi
}

calculate_hash() {
  local repo_full="$1"
  local rev="$2"
  local tarball_url="https://github.com/$repo_full/archive/$rev.tar.gz"

  if [[ -n "$GITHUB_TOKEN" ]]; then
    temp_dir=$(mktemp -d)
    temp_file="$temp_dir/archive.tar.gz"
    extract_dir="$temp_dir/extracted"

    if curl -s -L "${AUTH_ARGS[@]}" -o "$temp_file" "$tarball_url" && \
       mkdir -p "$extract_dir" && \
       tar -xzf "$temp_file" -C "$extract_dir" --strip-components=1 && \
       raw_hash=$(nix-hash --type sha256 --base32 "$extract_dir" 2>/dev/null); then
      hash=$(nix hash to-sri --type sha256 "$raw_hash" 2>/dev/null || echo "sha256-$raw_hash")
      rm -rf "$temp_dir"
    else
      rm -rf "$temp_dir"
      echo "⚠️  Authenticated download failed, falling back to nix-prefetch-url..."
      raw_hash=$(nix-prefetch-url --unpack "$tarball_url" 2>/dev/null || echo "")
      if [[ -n "$raw_hash" ]]; then
        hash=$(nix hash to-sri --type sha256 "$raw_hash" 2>/dev/null || echo "sha256-$raw_hash")
      fi
    fi
  else
    raw_hash=$(nix-prefetch-url --unpack "$tarball_url" 2>/dev/null || echo "")
    if [[ -n "$raw_hash" ]]; then
      hash=$(nix hash to-sri --type sha256 "$raw_hash" 2>/dev/null || echo "sha256-$raw_hash")
    fi
  fi

  if [[ -z "$hash" ]]; then
    echo "❌ Could not calculate hash"
    return 1
  fi
}