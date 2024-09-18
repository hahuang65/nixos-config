{ config, lib, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  inherit (lib.lists) forEach;
in
{
  options = {
    sway = {
      enable = mkEnableOption "sway";

      users = mkOption {
        type = types.listOf types.str;
        description = "Users allowed to use sway";
      };
    };
  };

  config = mkIf config.sway.enable {
    hardware.opengl = {
      enable = true;
    };

    security.polkit.enable = true;
    security.pam.services.swaylock = { };

    # FIXME: This next bit doesn't work, but we should fix it instead of hard-coding
    # forEach config.sway.users (u:
    #   users.users.${u}.extraGroups += [ "video" ];
    # )
  };
}
