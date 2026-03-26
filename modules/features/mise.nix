{ self, inputs, ... }: {
  flake.homeModules.mise = { pkgs, ... }: {
    home.packages = [ pkgs.mise ];

    xdg.configFile."mise" = {
      source = ./mise;
      recursive = true;
    };
  };
}
