{ self, inputs, ... }: {
  flake.nixosModules.endor-configuration = { pkgs, lib, config, ... }: {
    imports = [
      self.nixosModules.endor-hardware
      self.nixosModules.desktop
    ];

    networking.hostName = "endor";
    system.stateVersion = "25.05";
  };
}
