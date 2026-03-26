{ self, inputs, ... }: {
  flake.nixosModules.endor-configuration = { pkgs, lib, config, ... }: {
    imports = [
      self.nixosModules.endor-hardware
      self.nixosModules.desktop
      self.nixosModules.home
      self.nixosModules.bluetooth
      self.nixosModules.podman
    ];

    networking.hostName = "endor";
    system.stateVersion = "25.05";

    home-manager.users.hao = {
      custom.senpai.enable = true;
    };
  };
}
