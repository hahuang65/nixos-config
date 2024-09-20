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
    senpai = {
      enable = mkEnableOption "senpai";
    };
  };

  config = mkIf config.senpai.enable {
    sops.secrets."sourcehut/chat/token" = { };

    home = {
      packages = [ pkgs.senpai ];
      file = {
        "${config.xdg.configHome}/senpai/highlight".source = ./highlight;

        # FIXME: Change these params into options that can be passed in
        "${config.xdg.configHome}/senpai/senpai.scfg".text = ''
          address "chat.sr.ht"
          nickname "hwrd"
          realname "Howard Huang"
          password-cmd cat ${config.sops.secrets."sourcehut/chat/token".path}
          highlight hwrd hahuang65

          pane-widths {
            channels 20
            nicknames 10
            members 14
          }
        '';
      };
    };
  };
}
