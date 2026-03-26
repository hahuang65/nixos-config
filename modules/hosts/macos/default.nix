{ self, inputs, ... }: {
  flake.darwinConfigurations.macos = inputs.nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    modules = [
      self.darwinModules.darwin
      self.darwinModules.fonts
      self.darwinModules.home
      inputs.sops-nix.darwinModules.sops
      inputs.home-manager.darwinModules.home-manager
    ];
  };
}
