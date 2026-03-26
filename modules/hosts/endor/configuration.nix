{ self, inputs, ... }: {
  flake.nixosModules.endor-configuration = { pkgs, lib, config, ... }: {
    imports = [
      self.nixosModules.endor-hardware
      self.nixosModules.desktop
      self.nixosModules.home
      self.nixosModules.podman
    ];

    networking.hostName = "endor";
    system.stateVersion = "25.05";
  };
}
