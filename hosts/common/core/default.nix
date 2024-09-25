{ configLib, pkgs, ... }:
{
  imports = (configLib.scanPaths ./.) ++ [ ]; # Any other imports go in here

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    gnumake
    nix-bundle
    openssh
    vim
    wget
  ];
}
