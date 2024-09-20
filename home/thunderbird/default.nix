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
    thunderbird = {
      enable = mkEnableOption "thunderbird";
    };
  };

  config = mkIf config.thunderbird.enable { home.packages = [ pkgs.thunderbird ]; };
}
