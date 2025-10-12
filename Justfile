[private]
default:
  @just --list

[private]
alias b := build

# Build the Nix configuration
[linux]
build:
  nixos-rebuild switch --flake .#`hostname` --use-remote-sudo

[private]
alias c := clean

# Cleanup unused nix store entries
clean:
  sudo nix-collect-garbage --delete-old

[private]
alias d := debug

# Build in debug mode (verbose, tracing, disable caching)
[linux]
debug:
  nixos-rebuild switch --flake .#`hostname` --use-remote-sudo --show-trace --verbose --option eval-cache false

[private]
alias h := history

# Show the history
history:
  nix profile history --profile /nix/var/nix/profiles/system

[private]
alias p := prune

# Prune old generations older than {{DAYS}} days
[confirm]
prune DAYS="7":
  sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  --older-than {{DAYS}}d

[private]
alias r := repl

# Start a REPL with nixpkgs loaded
repl:
  nix repl -f flake:nixpkgs

[private]
alias s := secrets

# Update the secrets flake
secrets:
	nix flake lock --update-input nix-secrets

[private]
alias u := update

# Update specified {{FLAKES}}, or all if blank
update:
  @echo "🔄 Updating GitHub packages..."
  @just update-neovim-github
  @echo "🔄 Updating flakes..."
  nix flake update

[private]
alias ug := update-neovim-github

[private]
alias ag := add-neovim-github

# Generate a fromGitHub function call for a given repository
add-neovim-github REPO:
  #!/usr/bin/env nix-shell
  #!nix-shell -i bash -p jq curl git gh wl-clipboard
  set -euo pipefail

  source <(cat <<'GITHUB_FUNCTIONS'

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
        hash="sha256-$raw_hash"
        rm -rf "$temp_dir"
      else
        rm -rf "$temp_dir"
        echo "⚠️  Authenticated download failed, falling back to nix-prefetch-url..."
        raw_hash=$(nix-prefetch-url --unpack "$tarball_url" 2>/dev/null || echo "")
        if [[ -n "$raw_hash" ]]; then
          hash="sha256-$raw_hash"
        fi
      fi
    else
      raw_hash=$(nix-prefetch-url --unpack "$tarball_url" 2>/dev/null || echo "")
      if [[ -n "$raw_hash" ]]; then
        hash="sha256-$raw_hash"
      fi
    fi

    if [[ -z "$hash" ]]; then
      echo "❌ Could not calculate hash"
      return 1
    fi
  }

  GITHUB_FUNCTIONS
  )

  REPO_FULL="{{REPO}}"

  # Validate repo format
  if [[ ! "$REPO_FULL" =~ ^[^/]+/[^/]+$ ]]; then
    echo "Error: Repository must be in format 'owner/repo'"
    echo "Example: just add-github nvim-treesitter/nvim-treesitter"
    exit 1
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
  echo
  echo "📋 Copy this to your Nix configuration:"
  echo

  # Generate the output
  output="(fromGitHub {
    repo = \"$REPO_FULL\";
    rev = \"$latest_rev\";
    hash = \"$hash\";
  })"

  echo "$output"

  # Copy to clipboard
  echo "$output" | wl-copy
  echo
  echo "✅ Copied to clipboard!"

# Update GitHub packages in home/neovim/default.nix
update-neovim-github:
  #!/usr/bin/env nix-shell
  #!nix-shell -i bash -p jq curl git gh
  set -euo pipefail

  NIX_FILE="home/neovim/default.nix"

  if [[ ! -f "$NIX_FILE" ]]; then
    echo "Error: $NIX_FILE not found"
    exit 1
  fi

  # Try to get GitHub token from available sources
  GITHUB_TOKEN=""
  if command -v gh >/dev/null && gh auth status >/dev/null 2>&1; then
    # Use GitHub CLI token if available
    GITHUB_TOKEN=$(gh auth token 2>/dev/null || echo "")
    if [[ -n "$GITHUB_TOKEN" ]]; then
      echo "🔑 Using GitHub CLI authentication"
    fi
  elif git config --global credential.helper >/dev/null 2>&1; then
    # Try to extract token from git credential helper
    GITHUB_TOKEN=$(printf "protocol=https\nhost=github.com\n" | git credential fill 2>/dev/null | grep "^password=" | cut -d'=' -f2 || echo "")
    if [[ -n "$GITHUB_TOKEN" ]]; then
      echo "🔑 Using git credential helper authentication"
    fi
  fi

  # Set up curl auth header if we have a token
  if [[ -n "$GITHUB_TOKEN" ]]; then
    AUTH_ARGS=("-H" "Authorization: token $GITHUB_TOKEN")
  else
    echo "⚠️  No GitHub authentication found - using anonymous access (lower rate limits)"
    AUTH_ARGS=()
  fi

  # Extract fromGitHub packages using awk
  packages=$(awk '
    /\(fromGitHub \{/ {
      in_block = 1
      repo_full = ""
      rev = ""
      hash = ""
    }
    in_block && /repo = "([^"]+)";/ {
      match($0, /repo = "([^"]+)";/, arr)
      repo_full = arr[1]
    }
    in_block && /rev = "([^"]+)";/ {
      match($0, /rev = "([^"]+)";/, arr)
      rev = arr[1]
    }
    in_block && /hash = "([^"]+)";/ {
      match($0, /hash = "([^"]+)";/, arr)
      hash = arr[1]
    }
    in_block && /\}\)/ {
      if (repo_full && rev && hash) {
        print repo_full ":" rev ":" hash
      }
      in_block = 0
    }
  ' "$NIX_FILE")

  if [[ -z "$packages" ]]; then
    echo "No fromGitHub packages found"
    exit 0
  fi

  updates_made=0

  echo "Found packages to potentially update:"

  while IFS=: read -r repo_full current_rev current_hash; do
    owner=$(echo "$repo_full" | cut -d'/' -f1)
    repo=$(echo "$repo_full" | cut -d'/' -f2)

    echo
    echo "Checking $repo_full..."
    echo "  Current: ${current_rev:0:8}"

    # First get the default branch, then get its latest commit
    default_branch=$(curl -s -H "Accept: application/vnd.github.v3+json" \
      "${AUTH_ARGS[@]}" \
      "https://api.github.com/repos/$repo_full" | \
      jq -r '.default_branch // empty' 2>/dev/null)

    if [[ -n "$default_branch" ]]; then
      latest_rev=$(curl -s -H "Accept: application/vnd.github.v3+json" \
        "${AUTH_ARGS[@]}" \
        "https://api.github.com/repos/$repo_full/commits/$default_branch" | \
        jq -r '.sha // empty' 2>/dev/null)
      if [[ -z "$latest_rev" ]]; then
        echo "  ⚠️  Could not get latest commit from default branch '$default_branch'"
      fi
    else
      echo "  ⚠️  Could not determine default branch, trying main/master..."
      # Fallback to main/master
      latest_rev=$(curl -s -H "Accept: application/vnd.github.v3+json" \
        "${AUTH_ARGS[@]}" \
        "https://api.github.com/repos/$repo_full/commits/main" | \
        jq -r '.sha // empty' 2>/dev/null || \
        curl -s -H "Accept: application/vnd.github.v3+json" \
        "${AUTH_ARGS[@]}" \
        "https://api.github.com/repos/$repo_full/commits/master" | \
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

    # Get new hash - try authenticated download first, fallback to nix-prefetch-url
    echo "  🔍 Fetching hash for $repo_full@${latest_rev:0:8}..."
    tarball_url="https://github.com/$repo_full/archive/$latest_rev.tar.gz"

    # If we have auth, try downloading and calculating hash ourselves
    if [[ -n "$GITHUB_TOKEN" ]]; then
      temp_dir=$(mktemp -d)
      temp_file="$temp_dir/archive.tar.gz"
      extract_dir="$temp_dir/extracted"

      if curl -s -L "${AUTH_ARGS[@]}" -o "$temp_file" "$tarball_url" && \
         mkdir -p "$extract_dir" && \
         tar -xzf "$temp_file" -C "$extract_dir" --strip-components=1 && \
         raw_hash=$(nix-hash --type sha256 --base32 "$extract_dir" 2>/dev/null); then
        new_hash="sha256-$raw_hash"
        echo "  ✅ Got hash (authenticated): ${new_hash:0:16}..."
        rm -rf "$temp_dir"
      else
        echo "  ⚠️  Authenticated download failed, falling back to nix-prefetch-url..."
        rm -rf "$temp_dir"
        if raw_hash=$(nix-prefetch-url --unpack "$tarball_url" 2>/dev/null); then
          new_hash="sha256-$raw_hash"
          echo "  ✅ Got hash (fallback): ${new_hash:0:16}..."
        else
          echo "  ❌ Could not fetch hash, skipping this package"
          continue
        fi
      fi
    else
      # No auth available, use nix-prefetch-url directly
      if raw_hash=$(nix-prefetch-url --unpack "$tarball_url" 2>/dev/null); then
        new_hash="sha256-$raw_hash"
        echo "  ✅ Got hash: ${new_hash:0:16}..."
      else
        echo "  ❌ Could not fetch hash, skipping this package"
        continue
      fi
    fi

    # Update the file using sed - now looking for the new repo format
    escaped_repo_full=$(printf '%s\n' "$repo_full" | sed 's/[[\.*^$()+?{|]/\\&/g')
    if sed -i.bak \
      -e "/repo = \"$escaped_repo_full\";/{" \
      -e "N; s/rev = \"[^\"]*\";/rev = \"$latest_rev\";/" \
      -e "N; s/hash = \"[^\"]*\";/hash = \"$new_hash\";/" \
      -e "}" \
      "$NIX_FILE" 2>/dev/null && ! cmp -s "$NIX_FILE" "$NIX_FILE.bak"; then
      echo "  ✅ Updated to ${latest_rev:0:8}"
      updates_made=$((updates_made + 1))
      rm -f "$NIX_FILE.bak"
    else
      echo "  ❌ Failed to update in file"
      [[ -f "$NIX_FILE.bak" ]] && mv "$NIX_FILE.bak" "$NIX_FILE"
    fi

  done <<< "$packages"

  echo
  echo "🎉 Updated $updates_made packages"

  if [[ $updates_made -gt 0 ]]; then
    echo
    echo "Run 'just build' or 'home-manager switch' to apply the updates"
  fi
