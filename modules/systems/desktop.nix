{ self, inputs, ... }: {
  flake.nixosModules.desktop = { pkgs, ... }: {
    imports = [
      self.nixosModules.nixos
      self.nixosModules.fonts
      self.nixosModules.niri
      self.nixosModules.noctalia
      self.nixosModules.onepassword
      self.nixosModules.home
    ];
  };
}
