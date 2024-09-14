{ config, lib, unstable, ... }:
let
  inherit (lib) mkEnableOption mkIf;
in {
  options = {
    neovim = {
      enable = mkEnableOption "neovim";
    };
  };

  config = mkIf config.neovim.enable {
    programs.neovim = {
      enable = true;
      package = unstable.neovim-unwrapped;

      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      withNodeJs = true;
      withPython3 = true;
      withRuby = true;
    };
  };
}
