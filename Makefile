.PHONY=rebuild
rebuild:
	sudo nixos-rebuild switch --flake .#$(shell hostname)
