{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf;
in {
  options = {
    fonts = {
      enable = mkEnableOption "fonts";
    };
  };
  
  config = mkIf config.fonts.enable {
    fonts.fontconfig.enable = true;
  };
}
