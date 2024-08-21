{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf mkOption types;
in {
  options = {
    keychain = {
      enable = mkEnableOption "keychain";
      keys = mkOption {
        type = types.listOf types.str;
        default = [];
        example = [ "id_ed25519" "id_rsa" ];
        description = "SSH keys to load into keychain";
      };
    };
  };
  
  config = mkIf config.keychain.enable {
    services.ssh-agent.enable = true;
    programs.keychain = {
      enable = true;
      keys = config.keychain.keys;
    };
  };
}
