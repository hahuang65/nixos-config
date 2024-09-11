{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf;
in {
  options = {
    theme = {
      enable = mkEnableOption "theme";
    };
  };
  
  config = mkIf config.theme.enable {
    home.packages = [ pkgs.dconf ];

    gtk = {
      enable = true;

      theme = {
        name = "Arc-Dark";
        package = pkgs.arc-theme;
      };

      iconTheme = {
        name = "Arc";
        package = pkgs.arc-icon-theme;
      };
    };
  };
}
