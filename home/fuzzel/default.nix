{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
in {
  options = {
    fuzzel = {
      enable = mkEnableOption "fuzzel";
    };
  };
  
  config = mkIf config.fuzzel.enable {
    programs.fuzzel = {
      enable = true;
      settings = {
        main = {
          prompt = "❯ ";
          icon-theme= "Arc"; # FIXME: Make this an option, depends on installed themes
        };
      };
    };
  };
}
