{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
in
{
  options = {
    bat = {
      enable = mkEnableOption "bat";
    };
  };

  config = mkIf config.bat.enable {
    programs.bat = {
      enable = true;
      config = {
        style = "plain";
      };
    };
  };
}
