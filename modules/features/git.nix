{ self, inputs, ... }: {
  flake.homeModules.git = { pkgs, ... }: {
    programs.git.enable = true;

    programs.delta = {
      enable = true;
      enableGitIntegration = true;
    };

    xdg.configFile."git" = {
      source = ./git;
      recursive = true;
    };
  };
}
