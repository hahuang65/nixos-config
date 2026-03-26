{ self, inputs, ... }: {
  flake.homeModules.senpai = { pkgs, config, lib, ... }: {
    options.custom.senpai.enable = lib.mkEnableOption "senpai IRC client";

    config = lib.mkIf config.custom.senpai.enable {
      home.packages = [ pkgs.senpai ];

      sops.secrets."senpai/config" = {
        sopsFile = ../../secrets/common.yaml;
        path = "${config.xdg.configHome}/senpai/senpai.scfg";
      };
    };
  };
}
