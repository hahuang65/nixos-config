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
    sops.secrets."spotify/${osConfig.host.name}" = {
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
