{
  config,
  lib,
  pkgs,
  osConfig,
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

  config = mkIf config.spotify.enable {
    sops.secrets."spotify/${osConfig.networking.hostName}" = {
      path = "${config.xdg.cacheHome}/spotify-player/credentials.json";
    };

    home = {
      packages = [
        pkgs.spotify
        pkgs.spotify-player
      ];
    };
  };
}
