{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf mkOption types;
in {
  options = {
    _1password = {
      enable = mkEnableOption "1password";

      users = mkOption {
        type = types.listOf types.str;
        description = "Usernames allowed to use 1password";
      };

      browsers = mkOption {
        type = types.listOf types.str;
        default = [];
        example = [ "vivaldi-bin" "wavebox" ];
        description = "None standard browsers allowed to integrate with 1password";
      };
    };
  };
  
  config = mkIf config._1password.enable {
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "1password"
      "1password-gui"
      "1password-cli"
    ];

    programs._1password.enable = true;
    programs._1password-gui = {
      enable = true;
      polkitPolicyOwners = config._1password.users;
    };
    
    environment.etc = {
      "1password/custom_allowed_browsers" = {
        mode = "0755";
        text = lib.strings.concatStringsSep "\n" config._1password.browsers;
      };
    };
  };
}
