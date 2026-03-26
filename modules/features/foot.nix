{ self, inputs, ... }: {
  flake.homeModules.foot = { pkgs, lib, ... }: lib.mkIf pkgs.stdenv.isLinux {
    home.packages = [ pkgs.foot ];

    xdg.configFile."foot" = {
      source = ./foot;
      recursive = true;
    };
  };
}
