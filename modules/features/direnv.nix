{ self, inputs, ... }: {
  flake.homeModules.direnv = { pkgs, ... }: {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    xdg.configFile."direnv" = {
      source = ./direnv;
      recursive = true;
    };
  };
}
