{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
in
{
  options = {
    location = {
      enable = mkEnableOption "location";
    };
  };

  config = mkIf config.location.enable { services.geoclue2.enable = true; };
}
