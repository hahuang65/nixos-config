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

## home: run home-manager build for current user
.PHONY: home
home:
	home-manager switch --flake .#`whoami`

## home/debug: debug home-manager build for current user
.PHONY: home/debug
home/debug:
	home-manager switch --flake .#`whoami` --show-trace --verbose

## os: run NixOS build for the current host
.PHONY: os
os:
	sudo nixos-rebuild switch --flake .#`hostname`

## os/debug: debug NixOS build for current user
.PHONY: os/debug
	os/debug:
	nixos-rebuild switch --flake . --show-trace --verbose

## repl: start Nix REPL
.PHONY: repl
repl:
	nix repl -f flake:nixpkgs

## update: update flake, updates all if no flake specified
.PHONY: update
update:
	nix flake update "$@"
