## help: print this help message
.PHONY: help
help:
	@echo 'Usage:'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' | sed -e 's/^/ /'

## clean: clean up generations > 7 days old
.PHONY: clean
clean:
	sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  --older-than 7d

## gc: clean up un-used Nix store entries
.PHONY: gc
gc:
	sudo nix-collect-garbage --delete-old

## build: run NixOS build for the current host
.PHONY: build
build:
	# https://mgdm.net/weblog/nixos-with-private-flakes/#don-t-use-sudo-with-nixos-rebuild
	nixos-rebuild switch --flake .#`hostname` --use-remote-sudo

## build/debug: debug NixOS build for current user
.PHONY: build/debug
build/debug:
	nixos-rebuild switch --flake .#`hostname` --use-remote-sudo --show-trace --verbose  --option eval-cache false

## repl: start Nix REPL
.PHONY: repl
repl:
	nix repl -f flake:nixpkgs

## update: update flake, updates all if no flake specified
.PHONY: update
update:
	nix flake update

## update/secrets: update nix-secrets
.PHONY: update/secrets
update/secrets:
	nix flake lock --update-input nix-secrets
