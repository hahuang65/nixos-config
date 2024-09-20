{ config, lib, ... }:

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

    programs.senpai = {
      enable = true;
      config = {
        address = "chat.sr.ht";
        nickname = "hwrd";
        password-cmd = [
          "cat"
          config.sops.secrets."sourcehut/chat/token".path
        ];
      };
    };

    home.file = {
      "${config.xdg.configHome}/senpai/highlight".source = ./highlight;
    };
  };
}
