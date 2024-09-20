{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
in
{
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
          prompt = "❯  ";
          icon-theme = config.gtkTheme.iconTheme.name;
        };
      };
    };
  };
}
