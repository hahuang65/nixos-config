{ config, lib, ... }:

let
<<<<<<< HEAD
  inherit (lib) lists mkEnableOption mkIf mkOption types;
  cfg = config.users.hao;
=======
  inherit (lib) mkEnableOption mkIf mkOption types;
>>>>>>> 44ffca9 (WIP)
  baseGroups = [ "wheel" "networkmanager" ];
in {
  options = {
    users.hao = {
      extraGroups = mkOption {
        type = types.listOf types.str;
        description = "Extra groups to add user hao to";
      };
    };
  };

  config = {
    # Don't forget to `passwd`!
    users.users = {
      hao = {
        isNormalUser = true;
        home = "/home/hao";
        description = "Howard Huang";
        extraGroups = lists.unique(baseGroups ++ cfg.extraGroups);
      };
    };
  };
}
