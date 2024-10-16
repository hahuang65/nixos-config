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
    foot = {
      enable = mkEnableOption "foot";
    };
  };

  config = mkIf (stdenv.isLinux && config.foot.enable) {
    programs.foot = {
      enable = true;
      settings = {
        scrollback = {
          lines = 5000;
        };
        key-bindings = {
          scrollback-up-half-page = "Control+Shift+u";
          scrollback-down-half-page = "Control+Shift+d";
          show-urls-launch = "Control+Shift+o";
        };
      };
    };
  };
}
