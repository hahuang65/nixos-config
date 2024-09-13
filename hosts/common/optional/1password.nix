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
        description = "Non-standard browsers allowed to integrate with 1password";
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

    security.polkit = {
      enable = true;
      # FIXME: This should allow a specific list of users, rather than wheel group
      extraConfig = ''
        /* Allow members of the wheel group to execute the defined actions
         * without password authentication, similar to `sudo NOPASSWD:`
         */
        polkit.addRule(function(action, subject) {
          if ((action.id == "com.1password.1Password.authorizeSshAgent" ||
               action.id == "com.1password.1Password.authorizeCLI") &&
               subject.isInGroup("wheel"))
          {
            return polkit.Result.YES;
          }
        });
      '';
    };
  };
}
