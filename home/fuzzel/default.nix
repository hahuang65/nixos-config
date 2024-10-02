{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  inherit (pkgs) stdenv;
in
{
  options = {
    fuzzel = {
      enable = mkEnableOption "fuzzel";
    };
  };

  config = mkIf (stdenv.isLinux && config.fuzzel.enable) {
    programs.fuzzel = {
      enable = true;
      settings = {
        main = {
          prompt = "❯  ";
          icon-theme = config.gtkTheme.iconTheme.name;
        };
      };
    };
  };
}
