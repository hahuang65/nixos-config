{ self, inputs, ... }: {
  flake.homeModules.inputrc = { pkgs, ... }: {
    xdg.configFile."readline" = {
      source = ./inputrc;
      recursive = true;
    };
  };
}
