{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
in
{
  options = {
    bluetooth = {
      enable = mkEnableOption "bluetooth";
    };
  };

  config = mkIf config.bluetooth.enable {
    home.packages = with pkgs; [
      blueberry
      bluez
      bluez-tools
    ];
  };
}
