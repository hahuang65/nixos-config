{ self, inputs, ... }: {
  flake.homeModules.foot = { pkgs, lib, ... }: lib.mkIf pkgs.stdenv.isLinux {
    home.packages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.foot
    ];

    xdg.configFile."foot" = {
      source = ./foot;
      recursive = true;
    };
  };

  perSystem = { pkgs, lib, system, ... }: lib.optionalAttrs (lib.hasSuffix "linux" system) {
    packages.foot = pkgs.symlinkJoin {
      name = "foot-wrapped";
      paths = [ pkgs.foot ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/foot \
          --add-flags "--config ${./foot/foot.ini}"
      '';
    };
  };
}
