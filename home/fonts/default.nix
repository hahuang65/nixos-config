{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  customFonts = import ../../modules/fonts { inherit pkgs; };
in {
  options = {
    fonts = {
      enable = mkEnableOption "fonts";
    };
  };
  
  config = mkIf config.fonts.enable {
    fonts.fontconfig.enable = true;
    home.packages = [ customFonts.fonts ];
  };
}
