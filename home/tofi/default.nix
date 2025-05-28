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
    tofi = {
      enable = mkEnableOption "tofi";
    };
  };

  config = mkIf (stdenv.isLinux && config.tofi.enable) {
    programs.tofi = {
      enable = true;
      settings = {
        width = "100%";
        height = "100%";
        border-width = 0;
        outline-width = 0;
        padding-left = "45%";
        padding-top = "35%";
        result-spacing = 25;
        num-results = 8;
        font = config.stylix.fonts.monospace.name;
      };
    };
  };
}
