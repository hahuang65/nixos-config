{ self, inputs, ... }: {
  flake.homeModules.editor = { pkgs, ... }: {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      extraPackages = with pkgs; [
        lua-language-server
        nil
        gopls
        nodePackages.typescript-language-server
        stylua
        nixfmt
        gofumpt
        nodePackages.prettier
        gcc
        gnumake
        nodejs
      ];
    };

    xdg.configFile."nvim" = {
      source = ./editor;
      recursive = true;
    };
  };
}
