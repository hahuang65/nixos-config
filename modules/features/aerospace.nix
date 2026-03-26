{ self, inputs, ... }: {
  flake.darwinModules.aerospace = { pkgs, ... }: {
    # Aerospace is installed via Homebrew cask on macOS
    # Config is placed via home-manager
  };

  flake.homeModules.aerospace = { pkgs, lib, ... }: lib.mkIf pkgs.stdenv.isDarwin {
    xdg.configFile."aerospace" = {
      source = ./aerospace;
      recursive = true;
    };
  };
}
