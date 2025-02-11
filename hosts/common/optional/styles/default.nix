{
  config,
  configLib,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkOption types;
  customFonts = import (configLib.fromRoot "modules/fonts") { inherit pkgs; };
in
{
  options = {
    style = {
      wallpaper = mkOption {
        type = types.str;
        description = "Filename of image that exists in the wallpapers directory";
        example = "unicat.png";
      };

      colorscheme = mkOption {
        type = types.str;
        description = "YAML file in ${pkgs.base16-schemes}/share/themes";
        default = "catppuccin-mocha";
      };

      cursor = {
        name = mkOption {
          type = types.str;
          description = "Name of the cursor theme";
          default = "Bibata-Modern-Ice";
        };

        package = mkOption {
          type = types.package;
          description = "Package that contains the cursor theme with given name";
          default = pkgs.bibata-cursors;
        };

        size = mkOption {
          type = types.int;
          description = "Size of the cursor";
          default = 32;
        };
      };

      font = {
        style = {
          serif = mkOption {
            type = types.str;
            description = "Name of the serif font to use";
            default = "Noto Serif";
          };

          sansSerif = mkOption {
            type = types.str;
            description = "Name of the sans serif font to use";
            default = "Noto Sans";
          };

          monospace = mkOption {
            type = types.str;
            description = "Name of the monospace font to use";
            default = "Iosevka";
          };

          emoji = mkOption {
            type = types.str;
            description = "Name of the emoji font to use";
            default = "Noto Sans Emoji";
          };
        };

        size = {
          application = mkOption {
            type = types.int;
            description = "Font size for applications to use";
            default = 12;
          };

          desktop = mkOption {
            type = types.int;
            description = "Font size for WM (desktop chrome) to use";
            default = 10;
          };

          popup = mkOption {
            type = types.int;
            description = "Font size for notifications and pop-ups to use";
            default = 10;
          };

          terminal = mkOption {
            type = types.int;
            description = "Font size for terminal emulators to use";
            default = 12;
          };
        };
      };
    };
  };

  config = {
    environment.systemPackages = [ pkgs.dconf ];

    stylix = {
      enable = true;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/${config.style.colorscheme}.yaml";
      image = ./. + "/wallpapers/${config.style.wallpaper}";

      cursor = {
        name = config.style.cursor.name;
        package = config.style.cursor.package;
        size = config.style.cursor.size;
      };

      fonts = {
        serif = {
          package = customFonts.fonts;
          name = config.style.font.style.serif;
        };
        sansSerif = {
          package = customFonts.fonts;
          name = config.style.font.style.sansSerif;
        };
        monospace = {
          package = customFonts.fonts;
          name = config.style.font.style.monospace;
        };
        emoji = {
          package = customFonts.fonts;
          name = config.style.font.style.emoji;
        };

        sizes = {
          applications = config.style.font.size.application;
          desktop = config.style.font.size.desktop;
          popups = config.style.font.size.popup;
          terminal = config.style.font.size.terminal;
        };
      };
    };
  };
}
