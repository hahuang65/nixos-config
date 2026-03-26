{ self, inputs, ... }: {
  flake.nixosModules.podman = { pkgs, ... }: {
    virtualisation.containers.enable = true;
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
    };

    environment.systemPackages = with pkgs; [
      podman-compose
      podman-tui
    ];
  };
}
