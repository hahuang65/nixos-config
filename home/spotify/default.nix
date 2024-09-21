{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
in
{
  options = {
    spotify = {
      enable = mkEnableOption "spotify";
    };
  };

  config = mkIf config.spotify.enable { home.packages = [ pkgs.spotify ]; };
}
