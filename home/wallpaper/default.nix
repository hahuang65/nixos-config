{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
in {
  options = {
    wallpaper = {
      enable = mkEnableOption "wallpaper";
    };
  };
  
  config = mkIf config.wallpaper.enable {
    home.file = {
      "Pictures/Wallpapers" = {
        source = ./assets;
        recursive = true;
      };
    };
  };
}
