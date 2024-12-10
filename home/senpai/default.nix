{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.senpai;
in
{
  options = {
    senpai = {
      enable = mkEnableOption "senpai";
      server = mkOption {
        type = types.str;
        description = "Address of the IRC server";
      };

      nickname = mkOption {
        type = types.str;
        description = "Nickname for the user";
      };

      realName = mkOption {
        type = types.str;
        default = "";
        description = "Real name for the user";
      };

      highlightTokens = mkOption {
        type = types.listOf types.str;
        description = "List of tokens that should trigger highlighting";
      };

      widths = {
        channels = mkOption {
          type = types.int;
          default = 20;
          description = "Width of the channel pane";
        };

        nicknames = mkOption {
          type = types.int;
          default = 10;
          description = "Width of the nicknames pane";
        };

        members = mkOption {
          type = types.int;
          default = 15;
          description = "Width of the members pane";
        };
      };
    };
  };

  config = mkIf config.senpai.enable {
    sops.secrets."sourcehut/chat/token" = { };

    home = {
      packages = [ pkgs.senpai ];
      file = {
        "${config.xdg.configHome}/senpai/highlight".source = ./highlight;

        "${config.xdg.configHome}/senpai/senpai.scfg".text = ''
          address "${cfg.server}"
          nickname "${cfg.nickname}"
          realname "${cfg.realName}"
          password-cmd cat ${config.sops.secrets."sourcehut/chat/token".path}
          highlight ${lib.strings.concatStringsSep " " cfg.highlightTokens}

          pane-widths {
            channels ${builtins.toString cfg.widths.channels}
            nicknames ${builtins.toString cfg.widths.nicknames}
            members ${builtins.toString cfg.widths.members}
          }
        '';
      };
    };
  };
}
