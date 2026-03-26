{ self, inputs, ... }: {
  flake.nixosModules.noctalia = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.noctalia
    ];
  };

  perSystem = { pkgs, lib, system, ... }: lib.optionalAttrs (lib.hasSuffix "linux" system) {
    packages.noctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
      inherit pkgs;
      settings = {};
    };
  };
}
