{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
  inherit (pkgs) stdenv;
in
{
  options = {
    darkman = {
      enable = mkEnableOption "darkman";

      location = {
        # Defaults to Spring, TX
        lat = mkOption {
          type = types.float;
          default = 30.116866421141836;
        };
        long = mkOption {
          type = types.float;
          default = -95.35681905950295;
        };
      };
    };
  };

  config = mkIf (stdenv.isLinux && config.darkman.enable) {
    services.darkman = {
      enable = true;
      settings = {
        lat = config.darkman.location.lat;
        lng = config.darkman.location.long;
        usegeoclue = osConfig.services.geoclue2.enable;
      };
    };
  };
}
