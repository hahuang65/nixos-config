{ config, ... }:
{
  sops = {
    age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
    defaultSopsFile = "${config.xdg.configHome}/nix/secrets/secrets.yaml";
    validateSopsFiles = false;
  };
}
