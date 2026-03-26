{ self, inputs, ... }: {
  flake.nixosModules.bespin-configuration = { pkgs, lib, config, ... }: {
    imports = [
      self.nixosModules.bespin-hardware
      self.nixosModules.desktop
      self.nixosModules.home
      self.nixosModules.podman
    ];

    networking.hostName = "bespin";
    system.stateVersion = "25.05";

    # Laptop power management (tlp conflicts with power-profiles-daemon from shared nixos module)
    services.power-profiles-daemon.enable = false;
    services.thermald.enable = true;
    services.tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
      };
    };
  };
}
