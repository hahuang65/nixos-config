{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  options = {
    docker = {
      enable = mkEnableOption "docker";

      users = mkOption {
        type = types.listOf types.str;
        description = "Usernames allowed to use docker without sudo";
      };
    };

  };

  config = mkIf config.docker.enable {
    virtualisation.docker.enable = true;
    users.groups.docker.members = config.docker.users;

    environment.systemPackages = with pkgs; [
      docker
      docker-compose
    ];
  };
}
