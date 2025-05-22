{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf mkMerge;
in
{
  options = {
    gaming = {
      steam = {
        enable = mkEnableOption "Steam";
      };
      ffxiv = {
        enable = mkEnableOption "Final Fantasy XIV";
      };
      ps5 = {
        enable = mkEnableOption "Chiaki (PlayStation Remote Play)";
      };
      starcitizen = {
        enable = mkEnableOption "Star Citizen";
      };
      wow = {
        enable = mkEnableOption "World of Warcraft";
      };
    };
  };

  config = mkMerge [
    # Steam configuration
    (mkIf (config.gaming.steam.enable || config.gaming.wow.enable) {
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
        dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
        localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
      };

      environment.systemPackages = with pkgs; [
        protonup-qt
      ];
    })

    # WoW configuration
    (mkIf config.gaming.wow.enable {
      environment.systemPackages = with pkgs; [
        wowup-cf
      ];
    })

    # Chiaki configuration
    (mkIf config.gaming.ps5.enable {
      environment.systemPackages = with pkgs; [
        chiaki-ng
      ];
    })

    # FFXIV configuration
    (mkIf config.gaming.ffxiv.enable {
      environment.systemPackages = with pkgs; [
        xivlauncher
      ];
    })

    # Star Citizen configuration
    (mkIf config.gaming.starcitizen.enable {
      nix.settings = {
        substituters = [ "https://nix-gaming.cachix.org" ];
        trusted-public-keys = [ "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4=" ];
      };

      environment.systemPackages = with pkgs; [
        inputs.nix-citizen.packages.${system}.star-citizen
      ];
    })
  ];
}
