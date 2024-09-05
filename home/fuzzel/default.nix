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
          font = "Iosevka";
          prompt = "❯   ";
          icon-theme= "Arc";
        };
        colors = {
          background = "1e1d2fff";
          text = "988ba2ff";
          match = "f38ba8ff";
          selection = "cba6f7ff";
          selection-text = "11111bff";
          border = "c9cbffff";
        };
      };
    };
  };
}
