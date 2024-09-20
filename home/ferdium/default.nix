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
    ferdium = {
      enable = mkEnableOption "ferdium";
    };
  };

  config = mkIf config.ferdium.enable { home.packages = [ pkgs.ferdium ]; };
}
