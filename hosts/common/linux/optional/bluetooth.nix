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
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true;
        };
      };
    };
    hardware.pulseaudio.configFile = pkgs.writeText "default.pa" ''
      load-module module-bluetooth-policy auto_switch=2
      load-module module-bluetooth-discover
      ## module fails to load with 
      ##   module-bluez5-device.c: Failed to get device path from module arguments
      ##   module.c: Failed to load module "module-bluez5-device" (argument: ""): initialization failed.
      # load-module module-bluez5-device
      # load-module module-bluez5-discover
    '';
    hardware.pulseaudio.extraConfig = "
      load-module module-switch-on-connect
    ";

    systemd.user.services.mpris-proxy = {
      description = "Mpris proxy";
      after = [
        "network.target"
        "sound.target"
      ];
      wantedBy = [ "default.target" ];
      serviceConfig.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
    };

    environment.systemPackages = with pkgs; [
      blueberry
      bluez
      bluez-tools
    ];
  };
}
