{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
in
{
  options = {
    docker = {
      enable = mkEnableOption "docker";
    };
  };

  config = mkIf config.docker.enable {
    environment.systemPackages = with pkgs; [
      docker
      docker-compose
    ];
  };
}
