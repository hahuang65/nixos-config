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
    hut.enable = mkEnableOption "hut";
  };

  config = mkIf config.hut.enable {
    sops.secrets."sourcehut/cli/token" = { };

    home = {
      packages = [ pkgs.hut ];
      file = {
        "${config.xdg.configHome}/hut/config".text = ''
          instance "sr.ht" {
            access-token-cmd cat ${config.sops.secrets."sourcehut/cli/token".path}
          }
        '';
      };
    };
  };
}
