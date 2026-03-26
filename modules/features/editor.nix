{ self, inputs, ... }: {
  flake.homeModules.editor = { pkgs, ... }: {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      extraPackages = with pkgs; [
        gcc
        gnumake
        tree-sitter
      ];
    };

    xdg.configFile."nvim" = {
      source = ./editor;
      recursive = true;
    };
  };
}
