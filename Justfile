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
update *FLAKES:
  nix flake update {{FLAKES}}
