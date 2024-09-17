set positional-arguments

[private]
default:
  @just --list

[private]
alias h := home
[private]
alias o := os
[private]
alias dh := debug-home
[private]
alias do := debug-os

# Build home-manager configuration
@home:
  home-manager switch --flake .#`whoami`

# Build NixOS configuration
@os:
  sudo nixos-rebuild switch --flake .#`hostname`

# Debug home-manager configuration
@debug-home:
  home-manager switch --flake .#`whoami` --show-trace --verbose

# Debug NixOS configuration
@debug-os:
  nixos-rebuild switch --flake . --show-trace --verbose

# Get Git information to use in fetchGitHub
@git-info IDENTIFIER:
  nix run nixpkgs#nix-prefetch-github {{file_name(parent_directory(IDENTIFIER))}} {{file_name(IDENTIFIER)}} \
  | head -n -1 \
  | tail -n +2 \
  | sed -E 's/(^ *)"([^"]*)":/\1\2:/' \
  | sed 's/:/ =/' \
  | sed '/[^,] *$/s/$/,/' \
  | sed 's/,$/;/' \
  | awk '{$1=$1;print}'

# Update flakes by name; all if no names are passed in
@up:
  nix flake update "$@"

# Start the Nix REPL
@repl:
  nix repl -f flake:nixpkgs

# Clean up generations > 7 days old
@clean:
  sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  --older-than 7d

# Clean up un-used Nix store entries
@gc:
  sudo nix-collect-garbage --delete-old
