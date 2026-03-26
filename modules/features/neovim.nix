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
      source = ./neovim;
      recursive = true;
    };
  };

  perSystem = { pkgs, lib, ... }: {
    packages.nvim = let
      neovimConfig = pkgs.neovimUtils.makeNeovimConfig {
        withNodeJs = true;
        withPython3 = true;
        extraPython3Packages = ps: [ ps.pynvim ];
        extraLuaPackages = ps: [ ps.jsregexp ];
      };
    in pkgs.symlinkJoin {
      name = "nvim";
      paths = [ pkgs.neovim ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/nvim \
          --prefix PATH : "${lib.makeBinPath (with pkgs; [ gcc gnumake tree-sitter nodePackages.neovim ])}" \
          --add-flags "-u ${./neovim}/init.lua" \
          --set NVIM_APPNAME "nvim"
      '';
    };
  };
}
