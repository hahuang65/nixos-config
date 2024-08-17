{ pkgs, ... }:

{
  imports = [
    ../host.nix
    ./hardware-configuration.nix
    ../../nixosModules
  ];

  host.name = "endor";
  host.extraPkgs = with pkgs; [
    bluez
    bluez-tools
    docker
    docker-compose
  ];

  # Don't forget to `passwd`!
  users.users.hao = {
    isNormalUser = true;
    home = "/home/hao";
    description = "Howard Huang";
    extraGroups = [ "wheel" "networkmanager" ];
  };
  
  _1password.enable = true;
  _1password.users = [ "hao" ];
}
