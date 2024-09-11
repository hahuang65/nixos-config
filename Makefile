.PHONY=rebuild
rebuild:
	home-manager switch --flake .#$(shell whoami)

.PHONY=rebuild/trace
rebuild/trace:
	home-manager switch --show-trace --flake .#$(shell whoami)

.PHONY=rebuild/os
rebuild/os:
	sudo nixos-rebuild switch --flake .#$(shell hostname)
