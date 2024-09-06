{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;
in {
  options = {
    pipewire = {
      enable = mkEnableOption "pipewire";
    };
  };

  config = mkIf config.pipewire.enable {
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
      jack.enable = true;
    };
  };
}
