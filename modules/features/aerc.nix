{ self, inputs, ... }: {
  flake.homeModules.aerc = { pkgs, config, lib, ... }: {
    options.custom.aerc.enable = lib.mkEnableOption "aerc email client";

    config = lib.mkIf config.custom.aerc.enable {
      programs.aerc.enable = true;

      sops.secrets."aerc/account/config" = {
        sopsFile = ../../secrets/common.yaml;
        path = "${config.xdg.configHome}/aerc/accounts.conf";
      };
    };
  };
}
