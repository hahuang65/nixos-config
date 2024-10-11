{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
in
{
  options = {
    thunar = {
      enable = mkEnableOption "thunar";
    };
  };

  config = mkIf config.thunar.enable {
    programs.thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
      ];
    };

    # For integration with removable drives etc.
    services.gvfs.enable = true;
  };
}
