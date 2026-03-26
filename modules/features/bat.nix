{ self, inputs, ... }: {
  flake.homeModules.bat = { pkgs, ... }: {
    programs.bat.enable = true;

    xdg.configFile."bat" = {
      source = ./bat;
      recursive = true;
    };
  };
}
