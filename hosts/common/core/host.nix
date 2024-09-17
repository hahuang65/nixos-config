# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:
let
  inherit (lib) lists mkOption types;
  cfg = config.host;
  basePkgs = with pkgs; [
    git
    gnumake
    home-manager
    nix-bundle
    openssh
    vim
    wget
  ];
in {
  options = {
    host = {
      extraPkgs = mkOption {
        type = types.listOf types.package;
        default = [];
        description = "List of extra packages to install, on top of basePkgs";
      };

      name = mkOption {
        type = types.str;
        description = "Hostname for the system";
      };
    };
    
  };
  
  config = {
    # Hostname
    networking.hostName = cfg.name;

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = lists.unique(basePkgs ++ cfg.extraPkgs);
  };
}
