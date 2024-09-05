{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
in {
  options = {
    direnv = {
      enable = mkEnableOption "direnv";
    };
  };
  
  config = mkIf config.direnv.enable {
    programs.direnv = {
      enable = true;
      stdlib = ''
        #!/usr/bin/env bash

        if [ -e pyproject.toml ]; then
          if [ -n "$(poetry env info --path)" ]; then
            source "$(poetry env info --path)/bin/activate"
          fi
        fi
      '';
    };
  };
}
