.PHONY=rebuild
rebuild:
	home-manager switch --flake .#$(shell whoami)

.PHONY=os/rebuild
os/rebuild:
	sudo nixos-rebuild switch --flake .#$(shell hostname)
