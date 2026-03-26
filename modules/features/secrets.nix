{ self, inputs, ... }: {
  flake.nixosModules.secrets = { config, ... }: {
    sops = {
      defaultSopsFormat = "yaml";
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      age.keyFile = "/var/lib/sops-nix/key.txt";
      age.generateKey = true;
    };
  };

  flake.darwinModules.secrets = { config, ... }: let
    primaryUser = builtins.head (builtins.attrNames (
      builtins.removeAttrs config.users.users [ "root" "nobody" "daemon" ]
    ));
    home = config.users.users.${primaryUser}.home;
  in {
    sops = {
      defaultSopsFormat = "yaml";
      age.keyFile = "${home}/.config/sops/age/keys.txt";
    };
  };

  flake.homeModules.secrets = { config, ... }: {
    sops = {
      defaultSopsFile = ../../secrets/home.yaml;
      age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    };
  };
}
