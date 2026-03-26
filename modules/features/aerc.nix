{ self, inputs, ... }: {
  flake.homeModules.aerc = { pkgs, config, ... }: {
    programs.aerc.enable = true;

    sops.secrets."aerc/account/config" = {
      sopsFile = ../../secrets/common.yaml;
      path = "${config.xdg.configHome}/aerc/accounts.conf";
    };
  };
}
