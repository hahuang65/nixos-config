{ pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ../host.nix
      ./hardware-configuration.nix
    ];

  host.name = "endor";
  # host.extraPkgs = with pkgs; [ zsh ];

  # Don't forget to `passwd`!
  users.users.hao = {
    isNormalUser = true;
    home = "/home/hao";
    description = "Howard Huang";
    extraGroups = [ "wheel" "networkmanager" ];
  };
}
