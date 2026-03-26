{ self, inputs, ... }: {
  flake.homeModules.vivaldi = { pkgs, lib, ... }: lib.mkIf pkgs.stdenv.isLinux {
    home.packages = [
      (pkgs.vivaldi.override {
        proprietaryCodecs = true;
        enableWidevine = true;
      })
    ];
  };
}
