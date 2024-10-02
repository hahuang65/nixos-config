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
    bluetooth = {
      enable = mkEnableOption "bluetooth";
    };
  };

  config = mkIf config.bluetooth.enable {
    hardware.bluetooth.enable = true;

    environment.systemPackages = with pkgs; [
      blueberry
      bluez
      bluez-tools
    ];
  };
}
