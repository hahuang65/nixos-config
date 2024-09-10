{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  customFonts = import ../../font { inherit pkgs; };
in {
  options = {
    customFonts = {
      enable = mkEnableOption "customFonts";
    };
  };
  
  config = mkIf config.customFonts.enable {
    fonts.fontconfig.enable = true;
    home.packages = [ customFonts.fonts ];
  };
}
