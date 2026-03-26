{ self, inputs, ... }: {
  flake.homeModules.senpai = { pkgs, config, ... }: {
    home.packages = [ pkgs.senpai ];

    sops.secrets."senpai/config" = {
      sopsFile = ../../secrets/common.yaml;
      path = "${config.xdg.configHome}/senpai/senpai.scfg";
    };
  };
}
