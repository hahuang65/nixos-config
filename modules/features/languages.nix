{ self, inputs, ... }: {
  flake.homeModules.languages = { pkgs, lib, ... }: {
    home.packages = with pkgs; [
      # Go
      go
      delve
      (lib.lowPrio gotools)

      # Python
      (python3.withPackages (ps: [
        ps.debugpy
        ps.pynvim
      ]))

      # Ruby
      ruby
      rubocop
      rubyPackages.ruby-lsp

      # Node
      nodejs
      nodePackages.neovim
    ];
  };
}
