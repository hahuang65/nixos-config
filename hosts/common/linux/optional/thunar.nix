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
    environment.systemPackages = with pkgs; [
      kdePackages.ark
    ];

    programs = {
      xfconf.enable = true; # Saves settings, explicitly enabled since we're not running xfce
      thunar = {
        enable = true;
        plugins = with pkgs.xfce; [
          thunar-archive-plugin
          thunar-volman
        ];
      };
    };

    services = {
      gvfs.enable = true; # For integration with removable drives etc.
      tumbler.enable = true; # Image thumbnails
    };
  };
}
