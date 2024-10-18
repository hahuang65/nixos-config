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
    xdgConfig = {
      enable = mkEnableOption "xdgConfig";
    };
  };

  config = mkIf (stdenv.isLinux && config.xdgConfig.enable) {
    xdg = {
      portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-wlr
          xdg-desktop-portal-gtk
        ];
        config = {
          common = {
            default = [ "wlr" ];
          };
        };
      };

      mimeApps = {
        enable = true;
        defaultApplications = {
          "application/pdf" = [ "zathura.desktop" ];
          "inode/directory" = [ "thunar.desktop" ];
        };
      };

      # User directories
      userDirs = {
        enable = true;
        createDirectories = true;
      };
    };

  };
}
