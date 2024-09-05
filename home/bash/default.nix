{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
in {
  options = {
    bash = {
      enable = mkEnableOption "bash";
    };
  };
  
  config = mkIf config.bash.enable {
    programs.bash = {
      enable = true;
      shellAliases = {
        ll = "ls -l";
        ".." = "cd .. ";
      };
    };
  };
}
