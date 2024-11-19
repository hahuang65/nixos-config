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
          # If something isn't working, use the following to debug:
          # XDG_UTILS_DEBUG_LEVEL=2 xdg-mime query filetype <file>
          # XDG_UTILS_DEBUG_LEVEL=2 xdg-mime query default <filetype, i.e. application/pdf>
          # fd <desktop file, i.e. zathura.desktop> /
          "application/pdf" = [ "org.pwmt.zathura.desktop" ];
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
