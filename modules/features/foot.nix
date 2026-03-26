{ self, inputs, ... }: {
  flake.homeModules.foot = { pkgs, ... }: {
    home.packages = [ pkgs.foot ];

    xdg.configFile."foot" = {
      source = ./foot;
      recursive = true;
    };
  };
}
