{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;
in
{
  options = {
    touchpad = {
      enable = mkEnableOption "touchpad";
    };
  };

  config = mkIf config.touchpad.enable { services.libinput.enable = true; };
}
