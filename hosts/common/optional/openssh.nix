{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
in
{
  options = {
    openssh = {
      enable = mkEnableOption "openssh";
    };
  };

  config = mkIf config.openssh.enable {
    services.openssh = {
      enable = true;

      # require public key authentication for better security
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
    };
  };
}
