{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  inherit (pkgs) stdenv;
in
{
  options = {
    gtkTheme = {
      enable = mkEnableOption "gtkTheme";

      iconTheme = {
        name = mkOption {
          type = types.str;
          description = "Name of the GTK icon theme";
          default = "Arc";
        };

        package = mkOption {
          type = types.package;
          description = "Package that contains the icon theme with given name";
          default = pkgs.arc-icon-theme;
        };
      };

      theme = {
        name = mkOption {
          type = types.str;
          description = "Name of the GTK theme";
          default = "Arc-Dark";
        };

        package = mkOption {
          type = types.package;
          description = "Package that contains the theme with given name";
          default = pkgs.arc-theme;
        };
      };
    };
  };

  config = mkIf (stdenv.isLinux && config.gtkTheme.enable) {
    gtk = {
      enable = true;

      theme = {
        name = mkDefault config.gtkTheme.theme.name;
        package = mkDefault config.gtkTheme.theme.package;
      };

      iconTheme = {
        name = mkDefault config.gtkTheme.iconTheme.name;
        package = mkDefault config.gtkTheme.iconTheme.package;
      };
    };
  };
}
