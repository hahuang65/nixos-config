{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
in
{
  options = {
    direnv = {
      enable = mkEnableOption "direnv";
    };
  };

  config = mkIf config.direnv.enable {
    programs.direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;

      config.global.hide_env_diff = true;
    };
  };
}
