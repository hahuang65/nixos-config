{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf;
in {
  options = {
    mako = {
      enable = mkEnableOption "mako";
    };
  };
  
  config = mkIf config.mako.enable {
    home.packages = with pkgs; [
      libnotify
    ];

    services.mako = {
      enable = true;

      backgroundColor = "#1e1e2e";
      borderColor = "#89b4fa";
      borderSize = 2;
      font = "Iosevka 18";
      height = 300;
      progressColor = "over #313244";
      textColor = "#cdd6f4";
      width = 600;

      extraConfig = ''
        [urgency=low]
        default-timeout=10000

        [urgency=normal]
        default-timeout=10000
        
        [urgency=high]
        default-timeout=0
        border-color=#fab387
        text-color=#f28fad
      '';
    };

    xdg.configFile."mako/test.sh".source = ./test.sh;
  };
}
