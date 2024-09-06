{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
in {
  options = {
    wezterm = {
      enable = mkEnableOption "wezterm";
    };
  };
  
  config = mkIf config.wezterm.enable {
    programs.wezterm.enable = true;

    xdg.configFile."wezterm/wezterm.lua".source = ./wezterm.lua;
  };
}
