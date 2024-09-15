{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf;
in {
  options = {
    mako = {
      enable = mkEnableOption "mako";
    };
  };
  
  config = mkIf config.mako.enable {
    home.packages = with pkgs; [
      libnotify
      (import ./scripts/test.nix { inherit pkgs; })
    ];

    services.mako = {
      enable = true;

      borderSize = 2;
      height = 300;
      width = 600;
    };
  };
}
