{ self, inputs, ... }: {
  flake.homeModules.terminal = { pkgs, ... }: {
    home.packages = [ pkgs.wezterm ];

    xdg.configFile."wezterm" = {
      source = ./terminal;
      recursive = true;
    };
  };
}
